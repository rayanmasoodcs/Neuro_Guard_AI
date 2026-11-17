import 'package:flutter/material.dart';

class SeizurePredictionResult {
  final String seizureType;
  final double confidence;
  final String riskLevel;
  final List<String> eegPatterns;
  final List<double> featureImportance;
  final String rawAnalysis;
  final DateTime predictionTime;
  final String fileAnalyzed;
  final Map<String, double> seizureTypeScores;

  SeizurePredictionResult({
    required this.seizureType,
    required this.confidence,
    required this.riskLevel,
    required this.eegPatterns,
    required this.featureImportance,
    required this.rawAnalysis,
    required this.predictionTime,
    required this.fileAnalyzed,
    required this.seizureTypeScores,
  });

  factory SeizurePredictionResult.fromJson(Map<String, dynamic> json) {
    return SeizurePredictionResult(
      seizureType: json['seizure_type'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? 'Unknown',
      eegPatterns: List<String>.from(json['eeg_patterns'] as List? ?? []),
      featureImportance: List<double>.from(
        (json['feature_importance'] as List? ?? []).map((x) => (x as num).toDouble()),
      ),
      rawAnalysis: json['raw_analysis'] as String? ?? '',
      predictionTime: json['prediction_time'] != null
          ? DateTime.parse(json['prediction_time'] as String)
          : DateTime.now(),
      fileAnalyzed: json['file_analyzed'] as String? ?? 'Unknown',
      seizureTypeScores: Map<String, double>.from(
        (json['seizure_type_scores'] as Map? ?? {})
            .map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seizure_type': seizureType,
      'confidence': confidence,
      'risk_level': riskLevel,
      'eeg_patterns': eegPatterns,
      'feature_importance': featureImportance,
      'raw_analysis': rawAnalysis,
      'prediction_time': predictionTime.toIso8601String(),
      'file_analyzed': fileAnalyzed,
      'seizure_type_scores': seizureTypeScores,
    };
  }

  String getConfidenceText() => '${(confidence * 100).toStringAsFixed(1)}%';

  Color getConfidenceColor() {
    if (confidence >= 0.8) return Color(0xFF22C55E);
    if (confidence >= 0.6) return Color(0xFFFCD34D);
    return Color(0xFFEF4444);
  }

  Color getRiskColor() {
    switch (riskLevel) {
      case 'Low':
        return Color(0xFF22C55E);
      case 'Medium':
        return Color(0xFFFCD34D);
      case 'High':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  String getDetailedAnalysis() {
    final buffer = StringBuffer();
    buffer.writeln('Seizure Type: $seizureType');
    buffer.writeln('Confidence: ${getConfidenceText()}');
    buffer.writeln('Risk Level: $riskLevel');
    buffer.writeln('File Analyzed: $fileAnalyzed');
    buffer.writeln('Prediction Time: $predictionTime');
    buffer.writeln('');
    buffer.writeln('EEG Patterns Detected:');
    for (final pattern in eegPatterns) {
      buffer.writeln('  • $pattern');
    }
    buffer.writeln('');
    buffer.writeln('Raw Analysis:');
    buffer.writeln(rawAnalysis);
    return buffer.toString();
  }
}


/// Result for a single patient in a batch prediction.
class BatchPatientResult {
  final int patientNumber;
  final String seizureType;
  final double confidence;
  final String riskLevel;
  final String recommendation;
  final Map<String, dynamic> allScores;
  final bool hasError;

  BatchPatientResult({
    required this.patientNumber,
    required this.seizureType,
    required this.confidence,
    required this.riskLevel,
    required this.recommendation,
    required this.allScores,
    this.hasError = false,
  });

  factory BatchPatientResult.fromJson(Map<String, dynamic> json) {
    return BatchPatientResult(
      patientNumber: (json['patient_number'] as num?)?.toInt() ?? 0,
      seizureType: json['seizure_type'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? 'Low',
      recommendation: json['recommendation'] as String? ?? '',
      allScores: json['all_scores'] as Map<String, dynamic>? ?? {},
      hasError: json['error'] == true,
    );
  }

  Color getRiskColor() {
    switch (riskLevel) {
      case 'Low':
        return Color(0xFF22C55E);
      case 'Medium':
        return Color(0xFFFCD34D);
      case 'High':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }
}


/// Summary of an uploaded EEG dataset.
class DatasetSummary {
  final String format;
  final double sizeKb;
  final int totalRows;
  final int featureColumns;
  final bool hasLabelColumn;
  final int uniqueClasses;
  final Map<String, int> classDistribution;
  final bool isMultiPatient;
  final double samplingRateHz;
  final String filename;

  DatasetSummary({
    required this.format,
    required this.sizeKb,
    required this.totalRows,
    required this.featureColumns,
    required this.hasLabelColumn,
    required this.uniqueClasses,
    required this.classDistribution,
    required this.isMultiPatient,
    required this.samplingRateHz,
    required this.filename,
  });

  factory DatasetSummary.fromJson(Map<String, dynamic> json) {
    return DatasetSummary(
      format: json['format'] as String? ?? 'Unknown',
      sizeKb: (json['size_kb'] as num?)?.toDouble() ?? 0.0,
      totalRows: (json['total_rows'] as num?)?.toInt() ?? 0,
      featureColumns: (json['feature_columns'] as num?)?.toInt() ?? 0,
      hasLabelColumn: json['has_label_column'] == true,
      uniqueClasses: (json['unique_classes'] as num?)?.toInt() ?? 0,
      classDistribution: (json['class_distribution'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      isMultiPatient: json['is_multi_patient'] == true,
      samplingRateHz: (json['sampling_rate_hz'] as num?)?.toDouble() ?? 256.0,
      filename: json['filename'] as String? ?? '',
    );
  }
}
