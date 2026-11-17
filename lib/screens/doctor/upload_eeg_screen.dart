// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../responsive/responsive.dart';
import '../../services/prediction_service.dart';
import '../../models/seizure_prediction_model.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';

class UploadEEGScreen extends StatefulWidget {
  const UploadEEGScreen({super.key});

  @override
  State<UploadEEGScreen> createState() => _UploadEEGScreenState();
}

class _UploadEEGScreenState extends State<UploadEEGScreen> {
  String? uploadedFileName;
  Uint8List? uploadedBytes;
  SeizurePredictionResult? predictionResult;
  bool isAnalyzing = false;

  // New state for batch/multi-patient
  DatasetSummary? _datasetSummary;
  List<BatchPatientResult>? _batchResults;
  bool _isLoadingBatch = false;

  Future<void> _pickEEGFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'edf', 'dat'],
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final fileName = file.name;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).couldNotParse),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      setState(() {
        uploadedFileName = fileName;
        uploadedBytes = bytes;
        predictionResult = null;
        _datasetSummary = null;
        _batchResults = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).fileSelected}: $fileName')),
        );
      }

      // Auto-fetch dataset summary
      _fetchDatasetSummary();
    }
  }

  Future<void> _fetchDatasetSummary() async {
    if (uploadedBytes == null || uploadedFileName == null) return;

    try {
      final summary = await PredictionService().getDatasetSummary(
        fileBytes: uploadedBytes!,
        fileName: uploadedFileName!,
      );
      if (mounted) {
        setState(() {
          _datasetSummary = summary;
        });
      }
    } catch (e) {
      // silently ignore summary fetch failure
    }
  }

  Future<void> _analyzeEEG() async {
    if (uploadedBytes == null || uploadedFileName == null) return;

    setState(() {
      isAnalyzing = true;
      predictionResult = null;
      _batchResults = null;
    });

    try {
      // If multi-patient and format is text-based, run batch
      if (_datasetSummary != null && _datasetSummary!.isMultiPatient) {
        await _runBatchPrediction();
      } else {
        // Single patient prediction
        final result = await PredictionService().predictFromEEGFile(
          userId: 1,
          fileBytes: uploadedBytes!,
          fileName: uploadedFileName!,
          eegData: [],
        );

        if (mounted) {
          setState(() {
            predictionResult = result;
          });
        }

        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context).analysisComplete}: ${result.seizureType}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).analysisError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _runBatchPrediction() async {
    setState(() => _isLoadingBatch = true);
    try {
      final result = await PredictionService().predictBatch(
        userId: 1,
        fileBytes: uploadedBytes!,
        fileName: uploadedFileName!,
      );
      if (mounted && result != null) {
        final patients = result['patients'] as List? ?? [];
        setState(() {
          _batchResults = patients
              .map((p) => BatchPatientResult.fromJson(p as Map<String, dynamic>))
              .toList();
          _isLoadingBatch = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batch complete: ${_batchResults!.length} patients analyzed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBatch = false);
      }
    }
  }

  Future<void> _generateEEGGraph(int patientIndex) async {
    if (uploadedBytes == null || uploadedFileName == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating EEG graph...'), backgroundColor: Color(0xff0B8F55)),
    );

    try {
      final pngBase64 = await PredictionService().generateEEGGraph(
        fileBytes: uploadedBytes!,
        fileName: uploadedFileName!,
        patientIndex: patientIndex,
      );
      if (mounted && pngBase64 != null) {
        _showEEGGraphDialog(pngBase64, patientIndex);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate graph: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEEGGraphDialog(String pngBase64, int patientIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EEG Waveform - Patient ${patientIndex + 1}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0B8F55)),
              ),
              SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(base64Decode(pngBase64)),
              ),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    if (uploadedBytes == null || uploadedFileName == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating report...'), backgroundColor: Color(0xff0B8F55)),
    );

    try {
      final pdfBase64 = await PredictionService().generateReport(
        userId: 1,
        fileBytes: uploadedBytes!,
        fileName: uploadedFileName!,
        patientName: predictionResult?.seizureType ?? 'EEG Analysis',
      );
      if (mounted && pdfBase64 != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report generated successfully!'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report generation returned empty'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        title: Text(
          AppLocalizations.of(context).eegUploadTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).eegUploadHeader,
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).eegUploadDescription,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 25),

              // ---- File upload card ----
              _buildUploadCard(),

              // ---- Review Dataset card ----
              if (_datasetSummary != null)
                _buildDatasetReviewCard(),

              // ---- Status cards ----
              if (isAnalyzing || _isLoadingBatch)
                _buildLoadingCard(),

              // ---- Prediction results ----
              if (predictionResult != null && !isAnalyzing)
                _buildPredictionResults(),

              // ---- Batch results table ----
              if (_batchResults != null && _batchResults!.isNotEmpty)
                _buildBatchResultsTable(),

              // ---- Medical disclaimer ----
              if ((predictionResult != null || _batchResults != null) && !isAnalyzing)
                _buildDisclaimer(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          children: [
            Icon(Icons.upload_file, size: 60, color: Color(0xff0B8F55)),
            SizedBox(height: 18),
            Text(AppLocalizations.of(context).chooseEegDataset, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              AppLocalizations.of(context).uploadEegFormats,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _pickEEGFile,
                icon: Icon(Icons.folder_open),
                label: Text(AppLocalizations.of(context).chooseEegDataset, style: TextStyle(fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xff0B8F55),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            if (uploadedFileName != null) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xffE9FFF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xff0B8F55)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).fileSelected,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xff0B8F55)),
                          ),
                          Text(uploadedFileName!, style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetReviewCard() {
    final ds = _datasetSummary!;
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_rounded, color: Color(0xff0B8F55)),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context).datasetReview,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _summaryRow('Format', ds.format),
              _summaryRow('File Size', '${ds.sizeKb.toStringAsFixed(1)} KB'),
              _summaryRow('Total Rows', '${ds.totalRows}'),
              _summaryRow('Features', '${ds.featureColumns}'),
              if (ds.hasLabelColumn) ...[
                _summaryRow('Label Classes', '${ds.uniqueClasses}'),
                if (ds.classDistribution.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Distribution: ${ds.classDistribution.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ),
              ],
              if (ds.isMultiPatient)
                Container(
                  margin: EdgeInsets.only(top: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xff22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Multi-Patient Dataset - ${ds.totalRows} patients detected',
                    style: TextStyle(color: Color(0xff0B8F55), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isAnalyzing ? null : _analyzeEEG,
                  icon: Icon(Icons.psychology),
                  label: Text(ds.isMultiPatient
                      ? AppLocalizations.of(context).analyzeAllPatients
                      : AppLocalizations.of(context).uploadEegButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 20),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0B8F55))),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context).analyzingEeg, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(height: 8),
              Text(
                _isLoadingBatch ? 'Running batch AI classification on all patients' : 'Running AI classification model',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    final result = predictionResult!;
    return Column(
      children: [
        SizedBox(height: 25),
        Text(AppLocalizations.of(context).classificationResults, style: TextStyle(fontSize: Responsive.titleSize(context), fontWeight: FontWeight.bold)),
        SizedBox(height: 15),

        // Seizure type card
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: result.getConfidenceColor().withValues(alpha: 0.1),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 12, height: 60,
                  decoration: BoxDecoration(color: result.getConfidenceColor(), borderRadius: BorderRadius.circular(6)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.seizureType, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                        'Confidence: ${result.getConfidenceText()}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Risk level
        SizedBox(height: 15),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: result.getRiskColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      result.riskLevel == 'High' ? Icons.warning_rounded : Icons.info_rounded,
                      color: result.getRiskColor(), size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Risk Level', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text(
                        result.riskLevel,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: result.getRiskColor()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action buttons: Generate Graph + Export Report
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _generateEEGGraph(0),
                icon: Icon(Icons.show_chart, size: 18),
                label: Text(AppLocalizations.of(context).generateEegGraph, style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(0xff0B8F55),
                  side: BorderSide(color: Color(0xff0B8F55)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _exportReport,
                icon: Icon(Icons.picture_as_pdf, size: 18),
                label: Text(AppLocalizations.of(context).exportReport, style: TextStyle(fontSize: 12)),
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xff0B8F55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchResultsTable() {
    final results = _batchResults!;
    return Column(
      children: [
        SizedBox(height: 25),
        Row(
          children: [
            Icon(Icons.table_chart, color: Color(0xff0B8F55)),
            SizedBox(width: 8),
            Text(
              'Batch Results (${results.length} Patients)',
              style: TextStyle(fontSize: Responsive.titleSize(context), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 15),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: [
                DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Seizure Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Confidence', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Risk', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Recommendation', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Graph', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: results.map((r) {
                return DataRow(
                  color: WidgetStatePropertyAll(
                    r.riskLevel == 'High'
                        ? Color(0xFFEF4444).withValues(alpha: 0.08)
                        : r.riskLevel == 'Medium'
                            ? Color(0xFFFCD34D).withValues(alpha: 0.08)
                            : null,
                  ),
                  cells: [
                    DataCell(Text('${r.patientNumber}')),
                    DataCell(Text(r.hasError ? 'Error' : r.seizureType,
                        style: TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(r.hasError ? '-' : '${(r.confidence * 100).toStringAsFixed(1)}%')),
                    DataCell(Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.getRiskColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(r.hasError ? 'N/A' : r.riskLevel,
                          style: TextStyle(color: r.getRiskColor(), fontWeight: FontWeight.w600, fontSize: 11)),
                    )),
                    DataCell(SizedBox(
                      width: 140,
                      child: Text(r.hasError ? (r.recommendation) : r.recommendation,
                          style: TextStyle(fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(
                      r.hasError
                          ? Icon(Icons.error_outline, color: Colors.grey, size: 18)
                          : IconButton(
                              icon: Icon(Icons.show_chart, color: Color(0xff0B8F55), size: 18),
                              onPressed: () => _generateEEGGraph(r.patientNumber - 1),
                              tooltip: 'Generate EEG Graph',
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        // Export all reports
        SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _exportReport,
            icon: Icon(Icons.picture_as_pdf),
            label: Text('Export Batch Report'),
            style: FilledButton.styleFrom(
              backgroundColor: Color(0xff0B8F55),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFFCD34D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Disclaimer',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309), fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'This AI analysis is for informational purposes only. '
                  'Do not rely solely on these results for medical decisions. '
                  'Always consult with a qualified neurologist for diagnosis and treatment.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
