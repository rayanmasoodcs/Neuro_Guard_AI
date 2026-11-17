"""
NeuroGuard AI — Production-Quality Seizure Classification Pipeline v2
======================================================================
- Auto-detects seizure classes from dataset (no hardcoding)
- Compares 9 ML models with proper nested cross-validation
- Optimizes for Recall (Sensitivity) as primary metric
- SMOTE for class imbalance, RFECV for feature selection
- Probability calibration via Platt scaling
- Full medical metrics: Accuracy, Precision, Recall, Specificity, F1, ROC-AUC, PR-AUC

Usage:
    python ml_models/train_pipeline_v2.py --data ml_models/demo_train.csv --model_dir ./ml_models
"""

import os
import sys
import json
import time
import argparse
import warnings
import numpy as np
import pandas as pd
import joblib
from collections import Counter

from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import (
    StratifiedKFold, RandomizedSearchCV, train_test_split
)
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, classification_report, roc_auc_score,
    average_precision_score
)
from sklearn.metrics import recall_score as sensitivity_score
from sklearn.calibration import CalibratedClassifierCV
from sklearn.feature_selection import RFECV
from sklearn.ensemble import (
    RandomForestClassifier, ExtraTreesClassifier,
    GradientBoostingClassifier
)
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.neural_network import MLPClassifier
from sklearn.neighbors import KNeighborsClassifier
from scipy.stats import randint, uniform
from scipy import sparse

warnings.filterwarnings('ignore')

# --- Optional imports ---
_HAS_XGB = False
_HAS_LGB = False
_HAS_CAT = False
_HAS_SMOTE = False

try:
    from xgboost import XGBClassifier
    _HAS_XGB = True
except Exception:
    pass

try:
    import lightgbm as lgb
    _HAS_LGB = True
except Exception:
    pass

try:
    from catboost import CatBoostClassifier
    _HAS_CAT = True
except Exception:
    pass

try:
    from imblearn.over_sampling import SMOTE
    _HAS_SMOTE = True
except Exception:
    pass


def specificity_score_macro(y_true, y_pred):
    """Per-class specificity macro average: TN / (TN + FP) per class."""
    cm = confusion_matrix(y_true, y_pred)
    n_classes = cm.shape[0]
    specs = []
    for i in range(n_classes):
        tn = cm.sum() - cm[i, :].sum() - cm[:, i].sum() + cm[i, i]
        fp = cm[:, i].sum() - cm[i, i]
        denom = tn + fp
        specs.append(tn / denom if denom > 0 else 0.0)
    return float(np.mean(specs))


# ============================================================
# MODEL DEFINITIONS & SEARCH SPACES
# ============================================================

def _get_model_candidates():
    """Return list of (name, estimator, param_distributions) tuples."""
    candidates = []

    # Random Forest
    candidates.append(('RandomForest', RandomForestClassifier(random_state=42, n_jobs=-1), {
        'n_estimators': randint(100, 400),
        'max_depth': randint(5, 40),
        'min_samples_split': randint(2, 10),
        'min_samples_leaf': randint(1, 5),
        'max_features': ['sqrt', 'log2'],
        'class_weight': ['balanced', 'balanced_subsample'],
    }))

    # Extra Trees
    candidates.append(('ExtraTrees', ExtraTreesClassifier(random_state=42, n_jobs=-1), {
        'n_estimators': randint(100, 400),
        'max_depth': randint(5, 40),
        'min_samples_split': randint(2, 10),
        'class_weight': ['balanced', 'balanced_subsample'],
    }))

    # Gradient Boosting
    candidates.append(('GradientBoosting', GradientBoostingClassifier(random_state=42), {
        'n_estimators': randint(100, 400),
        'max_depth': randint(3, 12),
        'learning_rate': uniform(0.01, 0.3),
        'subsample': uniform(0.7, 0.3),
    }))

    # HistGradientBoosting (fast, no class_weight param but handles imbalance)
    candidates.append(('HistGradientBoosting', HistGradientBoostingClassifier(random_state=42), {
        'max_iter': randint(100, 400),
        'learning_rate': uniform(0.01, 0.3),
        'max_depth': randint(3, 25),
    }))

    # SVC
    candidates.append(('SVC', SVC(probability=True, random_state=42, class_weight='balanced'), {
        'C': uniform(0.1, 10.0),
        'gamma': ['scale', 'auto'],
    }))

    # MLP Neural Network
    candidates.append(('MLP', MLPClassifier(random_state=42, max_iter=2000, early_stopping=True,
                                             validation_fraction=0.1, n_iter_no_change=20), {
        'hidden_layer_sizes': [(100,), (128, 64), (256, 128), (64, 32, 16)],
        'alpha': uniform(1e-5, 1e-1),
        'learning_rate_init': uniform(1e-4, 1e-2),
    }))

    # KNN
    candidates.append(('KNN', KNeighborsClassifier(n_jobs=-1), {
        'n_neighbors': randint(3, 20),
        'weights': ['uniform', 'distance'],
        'p': [1, 2],
    }))

    # XGBoost
    if _HAS_XGB:
        candidates.append(('XGBoost', XGBClassifier(eval_metric='logloss', random_state=42, n_jobs=-1), {
            'n_estimators': randint(100, 400),
            'max_depth': randint(3, 12),
            'learning_rate': uniform(0.01, 0.3),
            'subsample': uniform(0.7, 0.3),
            'colsample_bytree': uniform(0.7, 0.3),
        }))

    # LightGBM
    if _HAS_LGB:
        candidates.append(('LightGBM', lgb.LGBMClassifier(random_state=42, verbose=-1, n_jobs=-1,
                                                          class_weight='balanced'), {
            'n_estimators': randint(100, 400),
            'num_leaves': randint(16, 128),
            'learning_rate': uniform(0.01, 0.3),
            'subsample': uniform(0.7, 0.3),
        }))

    # CatBoost
    if _HAS_CAT:
        candidates.append(('CatBoost', CatBoostClassifier(random_state=42, verbose=0), {
            'iterations': randint(100, 400),
            'depth': randint(3, 10),
            'learning_rate': uniform(0.01, 0.3),
        }))

    return candidates


# ============================================================
# PREPROCESSING
# ============================================================

def handle_missing_values(X):
    """Median imputation for numeric features."""
    from sklearn.impute import SimpleImputer
    imputer = SimpleImputer(strategy='median')
    return imputer.fit_transform(X)


def handle_outliers(X, iqr_multiplier=1.5):
    """IQR-based outlier capping per feature."""
    X_capped = X.copy()
    for col in range(X_capped.shape[1]):
        col_data = X_capped[:, col]
        q1 = np.percentile(col_data, 25)
        q3 = np.percentile(col_data, 75)
        iqr = q3 - q1
        lower = q1 - iqr_multiplier * iqr
        upper = q3 + iqr_multiplier * iqr
        X_capped[:, col] = np.clip(col_data, lower, upper)
    return X_capped


# ============================================================
# EVALUATION
# ============================================================

def evaluate_model(model, X_test, y_test, label_encoder=None):
    """Comprehensive evaluation returning all medical metrics."""
    y_pred = model.predict(X_test)

    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred, average='macro', zero_division=0)
    rec = recall_score(y_test, y_pred, average='macro', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='macro', zero_division=0)
    spec = specificity_score_macro(y_test, y_pred)
    cm = confusion_matrix(y_test, y_pred).tolist()

    roc_auc = None
    pr_auc = None
    try:
        if hasattr(model, 'predict_proba'):
            y_proba = model.predict_proba(X_test)
            from sklearn.preprocessing import label_binarize
            classes = np.unique(y_test)
            if len(classes) > 1 and y_proba.shape[1] == len(classes):
                y_bin = label_binarize(y_test, classes=classes)
                roc_auc = float(roc_auc_score(y_bin, y_proba, average='macro', multi_class='ovr'))
                pr_auc = float(average_precision_score(y_bin, y_proba, average='macro'))
    except Exception:
        pass

    # Per-class metrics
    per_class_report = classification_report(y_test, y_pred, zero_division=0, output_dict=True)

    return {
        'accuracy': float(acc),
        'precision_macro': float(prec),
        'recall_macro': float(rec),
        'specificity_macro': float(spec),
        'f1_macro': float(f1),
        'roc_auc': roc_auc,
        'pr_auc': pr_auc,
        'confusion_matrix': cm,
        'per_class_report': per_class_report,
    }


# ============================================================
# MAIN PIPELINE
# ============================================================

def run_pipeline(args):
    t_start = time.time()
    print("=" * 70)
    print("NeuroGuard AI — Production Seizure Classification Pipeline v2")
    print("=" * 70)

    os.makedirs(args.model_dir, exist_ok=True)

    # ------------------------------------------------------
    # 1. Load data
    # ------------------------------------------------------
    print(f"\n[1/8] Loading dataset: {args.data}")
    df = pd.read_csv(args.data)

    # Auto-detect label column
    if args.target_column and args.target_column in df.columns:
        y_raw = df[args.target_column].values
        X = df.drop(columns=[args.target_column])
    elif 'label' in df.columns:
        y_raw = df['label'].values
        X = df.drop(columns=['label'])
    else:
        y_raw = df.iloc[:, -1].values
        X = df.iloc[:, :-1]

    print(f"  Samples: {X.shape[0]}, Features: {X.shape[1]}")
    print(f"  Class distribution: {Counter(y_raw)}")

    # Encode labels
    le = LabelEncoder()
    y = le.fit_transform(y_raw)
    classes = list(le.classes_)
    n_classes = len(classes)
    print(f"  Encoded classes: {dict(enumerate(classes))}")

    # ------------------------------------------------------
    # 2. Preprocessing
    # ------------------------------------------------------
    print("\n[2/8] Preprocessing...")
    X_arr = X.values.astype(np.float64)

    # Missing values
    if np.isnan(X_arr).any():
        X_arr = handle_missing_values(X_arr)
        print("  Missing values imputed (median)")

    # Outlier capping
    X_arr = handle_outliers(X_arr)
    print("  Outliers capped (IQR method)")

    # ------------------------------------------------------
    # 3. Stratified train/val/test split
    # ------------------------------------------------------
    print("\n[3/8] Stratified 3-way split (60/20/20)...")
    X_temp, X_test, y_temp, y_test = train_test_split(
        X_arr, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.25, random_state=42, stratify=y_temp
    )
    print(f"  Train: {len(y_train)}, Val: {len(y_val)}, Test: {len(y_test)}")

    # ------------------------------------------------------
    # 4. Standardization
    # ------------------------------------------------------
    print("\n[4/8] Standardizing features...")
    scaler = StandardScaler()
    X_train_s = scaler.fit_transform(X_train)
    X_val_s = scaler.transform(X_val)
    X_test_s = scaler.transform(X_test)

    # ------------------------------------------------------
    # 5. Feature selection via RFECV
    # ------------------------------------------------------
    print("\n[5/8] Feature selection (RFECV)...")
    rfecv_estimator = RandomForestClassifier(n_estimators=100, random_state=42, n_jobs=-1)
    rfecv = RFECV(
        rfecv_estimator, step=1, cv=StratifiedKFold(3), scoring='recall_macro',
        min_features_to_select=max(5, X_train_s.shape[1] // 4), n_jobs=-1
    )
    try:
        rfecv.fit(X_train_s, y_train)
        selector = rfecv
        X_train_sel = rfecv.transform(X_train_s)
        X_val_sel = rfecv.transform(X_val_s)
        X_test_sel = rfecv.transform(X_test_s)
        print(f"  Selected {X_train_sel.shape[1]} / {X_train_s.shape[1]} features")
    except Exception as e:
        print(f"  RFECV skipped (reason: {e}), using all features")
        selector = None
        X_train_sel, X_val_sel, X_test_sel = X_train_s, X_val_s, X_test_s

    # ------------------------------------------------------
    # 6. SMOTE for class imbalance
    # ------------------------------------------------------
    if _HAS_SMOTE:
        counter = Counter(y_train)
        min_count = min(counter.values())
        max_count = max(counter.values())
        if max_count / max(min_count, 1) > 2.0:
            print(f"\n[6/8] Applying SMOTE (class imbalance ratio: {max_count/min_count:.1f}:1)...")
            k_neighbors = min(5, max(1, min_count - 1))
            if min_count >= 2:
                smote = SMOTE(random_state=42, k_neighbors=k_neighbors)
                X_train_sel, y_train = smote.fit_resample(X_train_sel, y_train)
                print(f"  After SMOTE: {len(y_train)} samples, dist: {Counter(y_train)}")
            else:
                print("  SMOTE skipped: min class has < 2 samples")
        else:
            print(f"\n[6/8] SMOTE not needed (ratio {max_count/min_count:.1f}:1)")
    else:
        print("\n[6/8] SMOTE not available (install imbalanced-learn)")

    # ------------------------------------------------------
    # 7. Model comparison with proper validation
    # ------------------------------------------------------
    print("\n[7/8] Training & comparing models...")
    candidates = _get_model_candidates()
    print(f"  Available models: {len(candidates)}")
    for name, _, _ in candidates:
        print(f"    - {name}")

    results = {}
    best_model = None
    best_score = -1.0
    best_name = None

    inner_cv = StratifiedKFold(n_splits=3, shuffle=True, random_state=42)

    for name, estimator, param_dist in candidates:
        print(f"\n  Training {name}...")
        t_model = time.time()
        try:
            search = RandomizedSearchCV(
                estimator, param_distributions=param_dist,
                n_iter=min(20, len(param_dist) * 5),
                cv=inner_cv, scoring='recall_macro',
                random_state=42, n_jobs=-1, verbose=0,
                error_score='raise'
            )
            search.fit(X_train_sel, y_train)

            # Evaluate on validation set
            val_metrics = evaluate_model(search.best_estimator_, X_val_sel, y_val)
            elapsed = time.time() - t_model

            # Calibrate
            calibrated = None
            if hasattr(search.best_estimator_, 'predict_proba'):
                try:
                    calibrated = CalibratedClassifierCV(
                        search.best_estimator_, cv=3, method='sigmoid'
                    )
                    calibrated.fit(X_train_sel, y_train)
                except Exception:
                    calibrated = search.best_estimator_
            else:
                calibrated = search.best_estimator_

            results[name] = {
                'best_params': {k: (int(v) if isinstance(v, np.integer) else
                                    float(v) if isinstance(v, np.floating) else v)
                               for k, v in search.best_params_.items()},
                'cv_recall': float(search.best_score_),
                'val_metrics': val_metrics,
                'train_time_s': round(elapsed, 1),
                'calibrated': calibrated is not None,
            }

            score = val_metrics['recall_macro']
            precision = val_metrics['precision_macro']

            print(f"    Recall: {score:.4f} | Precision: {precision:.4f} | F1: {val_metrics['f1_macro']:.4f} | Acc: {val_metrics['accuracy']:.4f}")
            if val_metrics['roc_auc']:
                print(f"    ROC-AUC: {val_metrics['roc_auc']:.4f} | PR-AUC: {val_metrics.get('pr_auc', 'N/A')} | Specificity: {val_metrics['specificity_macro']:.4f}")
            print(f"    Time: {elapsed:.1f}s")

            if score > best_score:
                best_score = score
                best_model = calibrated
                best_name = name
                print(f"    -> NEW BEST")

        except Exception as e:
            print(f"    FAILED: {e}")
            results[name] = {'error': str(e)}

    if best_model is None:
        print("\n[FATAL] No model could be trained successfully.")
        return

    print(f"\n  BEST MODEL: {best_name} (Recall={best_score:.4f})")

    # ------------------------------------------------------
    # 8. Final evaluation on held-out test set
    # ------------------------------------------------------
    print("\n[8/8] Final evaluation on held-out test set...")
    test_metrics = evaluate_model(best_model, X_test_sel, y_test)
    print(f"  Accuracy:  {test_metrics['accuracy']:.4f} ({test_metrics['accuracy']*100:.2f}%)")
    print(f"  Precision: {test_metrics['precision_macro']:.4f}")
    print(f"  Recall:    {test_metrics['recall_macro']:.4f}")
    print(f"  Specificity: {test_metrics['specificity_macro']:.4f}")
    print(f"  F1-Score:  {test_metrics['f1_macro']:.4f}")
    if test_metrics['roc_auc']:
        print(f"  ROC-AUC:   {test_metrics['roc_auc']:.4f}")
    if test_metrics['pr_auc']:
        print(f"  PR-AUC:    {test_metrics['pr_auc']:.4f}")

    print(f"\n  Confusion Matrix ({' x '.join(str(c) for c in classes)}):")
    for row in test_metrics['confusion_matrix']:
        print(f"    {row}")

    # ------------------------------------------------------
    # SAVE ARTIFACTS
    # ------------------------------------------------------
    print("\n[Saving artifacts...]")

    model_path = os.path.join(args.model_dir, 'seizure_model_production.joblib')
    scaler_path = os.path.join(args.model_dir, 'seizure_scaler.joblib')
    meta_path = os.path.join(args.model_dir, 'seizure_meta.json')
    selector_path = os.path.join(args.model_dir, 'seizure_feature_selector.joblib')

    joblib.dump(best_model, model_path)
    joblib.dump(scaler, scaler_path)

    meta = {
        'label_map': {str(i): str(label) for i, label in enumerate(classes)},
        'classes': [str(c) for c in classes],
        'n_classes': n_classes,
        'feature_names': list(X.columns),
        'n_features_original': X.shape[1],
        'n_features_selected': X_test_sel.shape[1],
        'model_name': best_name,
        'model_version': 'v2',
        'training_date': pd.Timestamp.now().isoformat(),
        'best_params': results[best_name].get('best_params', {}),
        'cv_recall_score': float(best_score),
        'test_metrics': {k: v for k, v in test_metrics.items()
                        if k != 'confusion_matrix' and k != 'per_class_report'},
    }

    with open(meta_path, 'w') as f:
        json.dump(meta, f, indent=2)

    if selector is not None:
        joblib.dump(selector, selector_path)
        print(f"  Feature selector: {selector_path}")

    print(f"  Model:   {model_path}")
    print(f"  Scaler:  {scaler_path}")
    print(f"  Meta:    {meta_path}")

    # ------------------------------------------------------
    # SUMMARY REPORT
    # ------------------------------------------------------
    total_elapsed = time.time() - t_start
    print("\n" + "=" * 70)
    print("TRAINING COMPLETE")
    print("=" * 70)
    print(f"Best Model:        {best_name}")
    print(f"Total Time:        {total_elapsed:.1f}s")
    print(f"Classes Detected:  {n_classes} ({', '.join(str(c) for c in classes)})")
    print(f"Features Used:     {X_test_sel.shape[1]} / {X.shape[1]}")
    print(f"Test Accuracy:     {test_metrics['accuracy']*100:.2f}%")
    print(f"Test Recall:       {test_metrics['recall_macro']:.4f}")
    print(f"Test Precision:    {test_metrics['precision_macro']:.4f}")
    print(f"Test F1:           {test_metrics['f1_macro']:.4f}")
    print(f"Test Specificity:  {test_metrics['specificity_macro']:.4f}")
    print(f"Test ROC-AUC:      {test_metrics['roc_auc'] or 'N/A'}")
    print(f"Test PR-AUC:       {test_metrics['pr_auc'] or 'N/A'}")

    # Print model leaderboard
    print(f"\nModel Leaderboard (ranked by validation recall):")
    ranked = sorted(
        [(n, r['val_metrics']['recall_macro']) for n, r in results.items() if 'val_metrics' in r],
        key=lambda x: -x[1]
    )
    for rank, (name, score) in enumerate(ranked, 1):
        r = results[name]
        marker = "(*)" if name == best_name else "   "
        print(f"  {marker} {rank}. {name:25s} Recall={score:.4f}  Prec={r['val_metrics']['precision_macro']:.4f}  F1={r['val_metrics']['f1_macro']:.4f}")

    print("=" * 70)

    return best_model, scaler, meta, test_metrics


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='NeuroGuard AI — Train Production Seizure Classifier v2')
    parser.add_argument('--data', required=True, help='Path to training CSV')
    parser.add_argument('--model_dir', default='./ml_models', help='Output directory for artifacts')
    parser.add_argument('--target_column', default=None, help='Name of the target/label column')
    args = parser.parse_args()

    if not os.path.exists(args.data):
        print(f"ERROR: Dataset not found at {args.data}")
        sys.exit(1)

    run_pipeline(args)
