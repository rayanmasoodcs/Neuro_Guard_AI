"""
NeuroGuard AI - Production-Grade Random Forest Seizure Classification Model
============================================================================
Trains and validates a Random Forest classifier for 5-class epileptic seizure detection.
Target Accuracy: 97%+ with comprehensive cross-validation and hyperparameter optimization.

Dataset: BEED_Data_5_Classes.csv (5 seizure types)
- Class 0: Seizure Type 1 (Focal onset)
- Class 1: Seizure Type 2 (Generalized onset)
- Class 2: Seizure Type 3 (Unknown onset)
- Class 3: Seizure Type 4 (Non-convulsive)
- Class 4: Seizure Type 5 (Control - Normal EEG)
"""

import numpy as np
import pandas as pd
import joblib
import os
from sklearn.model_selection import StratifiedKFold, cross_val_score, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    confusion_matrix, classification_report, roc_auc_score, auc, roc_curve
)
from sklearn.preprocessing import label_binarize
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')


class SeizureModelTrainer:
    """Production-grade Random Forest trainer for seizure classification."""
    
    def __init__(self, data_path, model_output_dir='./ml_models'):
        """Initialize trainer with dataset path."""
        self.data_path = data_path
        self.model_output_dir = model_output_dir
        os.makedirs(model_output_dir, exist_ok=True)
        
        self.X_train = None
        self.X_test = None
        self.y_train = None
        self.y_test = None
        self.model = None
        self.scaler = StandardScaler()
        
        # Seizure type mappings
        self.seizure_types = {
            0: 'Focal Onset',
            1: 'Generalized Onset',
            2: 'Unknown Onset',
            3: 'Non-Convulsive',
            4: 'Normal (Control)'
        }
    
    def load_and_preprocess(self, test_size=0.2, random_state=42):
        """Load EEG data and preprocess for model training."""
        print("[LOADING] Reading EEG dataset...")
        df = pd.read_csv(self.data_path)
        
        print(f"[DATASET] Loaded {df.shape[0]} samples")
        
        if 'Patient_ID' not in df.columns:
            raise ValueError("CRITICAL: Patient_ID column is missing. This is required to prevent data leakage (patient cross-contamination). Please add a Patient_ID column to BEED_Data_5_Classes.csv.")
            
        self.groups = df['Patient_ID'].values
        df_features = df.drop(columns=['Patient_ID'])
        
        # Separate features and target
        X = df_features.iloc[:, :-1].values
        y = df_features.iloc[:, -1].values
        
        print(f"[CLASSES] Distribution: {np.bincount(y.astype(int))}")
        
        # Standardize features
        X_scaled = self.scaler.fit_transform(X)
        
        # Split into train/test with patient grouping
        from sklearn.model_selection import GroupShuffleSplit
        gss = GroupShuffleSplit(n_splits=1, test_size=test_size, random_state=random_state)
        train_idx, test_idx = next(gss.split(X_scaled, y, groups=self.groups))
        
        self.X_train, self.X_test = X_scaled[train_idx], X_scaled[test_idx]
        self.y_train, self.y_test = y[train_idx], y[test_idx]
        self.groups_train, self.groups_test = self.groups[train_idx], self.groups[test_idx]
        
        train_patients = set(self.groups_train)
        test_patients = set(self.groups_test)
        print(f"[SPLIT] Train patients: {len(train_patients)}, Test patients: {len(test_patients)}")
        print(f"[SPLIT] Leakage check (train_patients & test_patients): {train_patients & test_patients}")
        
        print(f"[SPLIT] Training samples: {len(self.y_train)}, Test samples: {len(self.y_test)}")
        return self.X_train, self.X_test, self.y_train, self.y_test
    
    def hyperparameter_tuning(self):
        """GridSearchCV to find optimal hyperparameters."""
        print("\n[TUNING] Starting hyperparameter optimization...")
        
        param_grid = {
            'n_estimators': [100, 200, 300],
            'max_depth': [15, 20, 25, None],
            'min_samples_split': [2, 5, 10],
            'min_samples_leaf': [1, 2, 4],
            'max_features': ['sqrt', 'log2'],
            'class_weight': ['balanced', 'balanced_subsample']
        }
        
        rf_base = RandomForestClassifier(random_state=42, n_jobs=-1)
        
        grid_search = GridSearchCV(
            rf_base, param_grid, cv=5, scoring='f1_weighted',
            n_jobs=-1, verbose=2
        )
        
        grid_search.fit(self.X_train, self.y_train)
        
        print(f"[TUNING] Best parameters: {grid_search.best_params_}")
        print(f"[TUNING] Best CV score: {grid_search.best_score_:.4f}")
        
        return grid_search.best_estimator_
    
    def train_model(self, use_tuning=True):
        """Train Random Forest with optimal or standard parameters."""
        print("\n[TRAINING] Initializing Random Forest model...")
        
        if use_tuning:
            self.model = self.hyperparameter_tuning()
        else:
            # Standard high-performance parameters
            self.model = RandomForestClassifier(
                n_estimators=250,
                max_depth=20,
                min_samples_split=5,
                min_samples_leaf=2,
                max_features='sqrt',
                class_weight='balanced_subsample',
                random_state=42,
                n_jobs=-1,
                verbose=1
            )
            print("[TRAINING] Fitting model with optimized parameters...")
            self.model.fit(self.X_train, self.y_train)
        
        return self.model
    
    def cross_validate(self, cv=10):
        """Perform k-fold cross-validation for robustness."""
        print(f"\n[VALIDATION] Running {cv}-fold cross-validation...")
        
        from sklearn.model_selection import GroupKFold
        gkf = GroupKFold(n_splits=min(cv, len(np.unique(self.groups_train))))
        
        scores = {
            'accuracy': cross_val_score(self.model, self.X_train, self.y_train, groups=self.groups_train, cv=gkf, scoring='accuracy'),
            'precision': cross_val_score(self.model, self.X_train, self.y_train, groups=self.groups_train, cv=gkf, scoring='precision_weighted'),
            'recall': cross_val_score(self.model, self.X_train, self.y_train, groups=self.groups_train, cv=gkf, scoring='recall_weighted'),
            'f1': cross_val_score(self.model, self.X_train, self.y_train, groups=self.groups_train, cv=gkf, scoring='f1_weighted')
        }
        
        print(f"\n[CV RESULTS]")
        for metric, cv_scores in scores.items():
            print(f"  {metric.upper()}: {cv_scores.mean():.4f} (+/- {cv_scores.std():.4f})")
        
        return scores
    
    def evaluate(self):
        """Evaluate model on test set with comprehensive metrics."""
        print("\n[EVALUATION] Testing on held-out test set...")
        
        y_pred = self.model.predict(self.X_test)
        
        # Main metrics
        accuracy = accuracy_score(self.y_test, y_pred)
        precision = precision_score(self.y_test, y_pred, average='weighted', zero_division=0)
        recall = recall_score(self.y_test, y_pred, average='weighted', zero_division=0)
        f1 = f1_score(self.y_test, y_pred, average='weighted', zero_division=0)
        
        print(f"\n[TEST METRICS]")
        print(f"  Accuracy:  {accuracy:.4f} ({accuracy*100:.2f}%)")
        print(f"  Precision: {precision:.4f}")
        print(f"  Recall:    {recall:.4f}")
        print(f"  F1-Score:  {f1:.4f}")
        
        # Per-class report
        print(f"\n[PER-CLASS REPORT]")
        report = classification_report(self.y_test, y_pred, 
                                      target_names=[self.seizure_types[i] for i in range(5)],
                                      zero_division=0)
        print(report)
        
        # Confusion matrix
        cm = confusion_matrix(self.y_test, y_pred)
        print(f"\n[CONFUSION MATRIX]")
        print(cm)
        
        return {
            'accuracy': accuracy,
            'precision': precision,
            'recall': recall,
            'f1': f1,
            'confusion_matrix': cm,
            'y_pred': y_pred,
            'y_test': self.y_test
        }
    
    def feature_importance(self, top_n=20):
        """Analyze top N most important features."""
        print(f"\n[FEATURE IMPORTANCE] Top {top_n} features:")
        
        importances = self.model.feature_importances_
        indices = np.argsort(importances)[::-1][:top_n]
        
        for rank, idx in enumerate(indices, 1):
            print(f"  {rank}. EEG_Signal_{idx+1}: {importances[idx]:.4f}")
        
        return importances
    
    def save_model(self, filename='seizure_model_production.pkl'):
        """Save trained model and scaler for deployment."""
        model_path = os.path.join(self.model_output_dir, filename)
        scaler_path = os.path.join(self.model_output_dir, 'seizure_scaler.pkl')
        
        joblib.dump(self.model, model_path)
        joblib.dump(self.scaler, scaler_path)
        joblib.dump(self.seizure_types, os.path.join(self.model_output_dir, 'seizure_types.pkl'))
        
        print(f"\n[SAVED] Model: {model_path}")
        print(f"[SAVED] Scaler: {scaler_path}")
        print(f"[SAVED] Seizure types: {os.path.join(self.model_output_dir, 'seizure_types.pkl')}")
        
        return model_path, scaler_path
    
    def plot_confusion_matrix(self, y_test, y_pred, filename='confusion_matrix.png'):
        """Visualize confusion matrix."""
        cm = confusion_matrix(y_test, y_pred)
        
        plt.figure(figsize=(10, 8))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                   xticklabels=[self.seizure_types[i] for i in range(5)],
                   yticklabels=[self.seizure_types[i] for i in range(5)])
        plt.title('Seizure Classification Confusion Matrix')
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        
        path = os.path.join(self.model_output_dir, filename)
        plt.savefig(path, dpi=300, bbox_inches='tight')
        print(f"[SAVED] Confusion Matrix: {path}")
        plt.close()
    
    def run_full_pipeline(self):
        """Execute complete training pipeline."""
        print("="*70)
        print("NeuroGuard AI - Seizure Model Training Pipeline")
        print("="*70)
        
        # 1. Load and preprocess
        self.load_and_preprocess()
        
        # 2. Train model with tuning
        self.train_model(use_tuning=True)
        
        # 3. Cross-validate
        self.cross_validate(cv=10)
        
        # 4. Evaluate
        eval_results = self.evaluate()
        
        # 5. Feature importance
        self.feature_importance(top_n=20)
        
        # 6. Visualizations
        self.plot_confusion_matrix(eval_results['y_test'], eval_results['y_pred'])
        
        # 7. Save artifacts
        self.save_model()
        
        print("\n" + "="*70)
        print(f"✓ Training Complete - Accuracy: {eval_results['accuracy']*100:.2f}%")
        print("="*70)
        
        return eval_results


if __name__ == '__main__':
    # Find the dataset
    data_paths = [
        'C:\\Users\\Maniha IMAN\\Copy\\BEED_Data_5_Classes.csv',
        './BEED_Data_5_Classes.csv',
        '../../../Copy/BEED_Data_5_Classes.csv'
    ]
    
    data_path = None
    for path in data_paths:
        if os.path.exists(path):
            data_path = path
            break
    
    if not data_path:
        print("❌ ERROR: BEED_Data_5_Classes.csv not found. Please provide correct path.")
        exit(1)
    
    # Train model
    trainer = SeizureModelTrainer(data_path)
    results = trainer.run_full_pipeline()
