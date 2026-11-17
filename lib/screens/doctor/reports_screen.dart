import 'package:flutter/material.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';
import '../../responsive/responsive.dart';
import 'upload_eeg_screen.dart';
import 'export_pdf_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget reportCard({
      required String patientName,
      required String reportDate,
      required String status,
      required Color statusColor,
    }) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(Icons.description_rounded, color: Color(0xff0B8F55)),
          ),
          title: Text(
            patientName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(reportDate),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {},
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EEG Reports",
              style: TextStyle(
                fontSize: Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              "Review uploaded EEG reports and AI-generated analysis.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: Responsive.subtitleSize(context),
              ),
            ),

            SizedBox(height: Responsive.spacing(context) * 1.5),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.padding(context)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff0B8F55), Color(0xff22C55E)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.analytics_rounded, color: Colors.white, size: 40),

                  SizedBox(height: 15),

                  Text(
                    "AI Report Analysis",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.titleSize(context),
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Upload an EEG report to receive seizure prediction and AI-powered neurological insights.",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: Responsive.spacing(context)),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadEEGScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xff0B8F55),
                    ),
                    icon: Icon(Icons.upload_file),
                    label: Text(AppLocalizations.of(context).uploadEegButton),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context) * 1.5),

            Text(
              "Recent Reports",
              style: TextStyle(
                fontSize: Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),
            reportCard(
              patientName: "Ali Raza",
              reportDate: "Today • 09:45 AM",
              status: "Normal",
              statusColor: Colors.green,
            ),

            SizedBox(height: Responsive.spacing(context)),

            reportCard(
              patientName: "Fatima Noor",
              reportDate: "Yesterday • 04:20 PM",
              status: "Observation",
              statusColor: Colors.orange,
            ),

            SizedBox(height: Responsive.spacing(context)),

            reportCard(
              patientName: "Ahmed Khan",
              reportDate: "Yesterday • 11:10 AM",
              status: "Emergency",
              statusColor: Colors.red,
            ),

            SizedBox(height: Responsive.spacing(context) * 1.5),

            Text(
              "AI Statistics",
              style: TextStyle(
                fontSize: Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: Icon(Icons.analytics, color: Color(0xff0B8F55)),
                title: Text(AppLocalizations.of(context).reportsProcessed),
                trailing: Text(
                  "89",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),

            SizedBox(height: Responsive.spacing(context)),
            Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: Responsive.titleSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 15),

            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadEEGScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.upload_file),
                  label: Text(AppLocalizations.of(context).uploadEeg),
                ),

                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExportPdfScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text(AppLocalizations.of(context).exportPdf),
                ),
              ],
            ),

            SizedBox(height: Responsive.spacing(context) * 1.5),

            Center(
              child: Column(
                children: [
                  Divider(),

                  SizedBox(height: 15),

                  Text(
                    "NeuroGuard AI",
                    style: TextStyle(
                      color: Color(0xff0B8F55),
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.subtitleSize(context),
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "AI Powered Epileptic Seizure Monitoring System",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Reports • Version 1.0.0",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "© 2026 NeuroGuard AI",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
