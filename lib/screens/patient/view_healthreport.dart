import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';
import '../doctor/export_pdf_screen.dart';

class ViewHealthReportScreen extends StatelessWidget {
  const ViewHealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),

      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        centerTitle: true,
        title: Text(
          "Health Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Patient Health Monitoring Report",
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "The following physiological parameters are collected from wearable sensors for AI-based epileptic seizure monitoring.",
                style: TextStyle(color: Colors.grey.shade700),
              ),

              SizedBox(height: 20),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),

                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),

                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                    },

                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xffE9FFF4),
                        ),

                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Health Parameter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              "Current Value",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [_tableCell("Heart Rate"), _tableCell("")],
                      ),

                      TableRow(
                        children: [
                          _tableCell("Body Temperature"),
                          _tableCell(""),
                        ],
                      ),

                      TableRow(
                        children: [_tableCell("Body Motion"), _tableCell("")],
                      ),

                      TableRow(
                        children: [_tableCell("Body Rotation"), _tableCell("")],
                      ),

                      TableRow(
                        children: [_tableCell("Accelerometer"), _tableCell("")],
                      ),

                      TableRow(
                        children: [_tableCell("Gyroscope"), _tableCell("")],
                      ),

                      TableRow(
                        children: [
                          _tableCell("Activity Level"),
                          _tableCell(""),
                        ],
                      ),

                      TableRow(
                        children: [
                          _tableCell("Fall Detection"),
                          _tableCell(""),
                        ],
                      ),

                      TableRow(
                        children: [_tableCell("Timestamp"), _tableCell("")],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExportPdfScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(Icons.description),
                  label: Text(
                    "View Report",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Text(text, style: TextStyle(fontSize: 15)),
    );
  }
}


