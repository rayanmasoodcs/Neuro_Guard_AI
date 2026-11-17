import 'package:flutter/material.dart';
import '../../responsive/responsive.dart';

class ExportPdfScreen extends StatefulWidget {
  const ExportPdfScreen({super.key});

  @override
  State<ExportPdfScreen> createState() => _ExportPdfScreenState();
}

class _ExportPdfScreenState extends State<ExportPdfScreen> {
  bool includePatientInfo = true;
  bool includeDiagnosis = true;
  bool includeEEGGraphs = true;
  bool includeDoctorNotes = true;

  bool pdfGenerated = false;

  final String fileName =
      "EEG_Report_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0B8F55),
        title: Text(
          "Export PDF",
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
                "Generate EEG Report",
                style: TextStyle(
                  fontSize: Responsive.titleSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 8),

              Text(
                "Select the information you want to include in the exported PDF report.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: Responsive.subtitleSize(context),
                ),
              ),

              SizedBox(height: Responsive.spacing(context)),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: includePatientInfo,
                        activeColor: Color(0xff0B8F55),
                        title: Text("Patient Information"),
                        secondary: Icon(Icons.person),
                        onChanged: (value) {
                          setState(() {
                            includePatientInfo = value!;
                          });
                        },
                      ),

                      Divider(),

                      CheckboxListTile(
                        value: includeDiagnosis,
                        activeColor: Color(0xff0B8F55),
                        title: Text("AI Diagnosis"),
                        secondary: Icon(Icons.psychology),
                        onChanged: (value) {
                          setState(() {
                            includeDiagnosis = value!;
                          });
                        },
                      ),

                      Divider(),

                      CheckboxListTile(
                        value: includeEEGGraphs,
                        activeColor: Color(0xff0B8F55),
                        title: Text("EEG Graphs"),
                        secondary: Icon(Icons.show_chart),
                        onChanged: (value) {
                          setState(() {
                            includeEEGGraphs = value!;
                          });
                        },
                      ),
                      Divider(),

                      CheckboxListTile(
                        value: includeDoctorNotes,
                        activeColor: Color(0xff0B8F55),
                        title: Text("Doctor Notes"),
                        secondary: Icon(Icons.note_alt_outlined),
                        onChanged: (value) {
                          setState(() {
                            includeDoctorNotes = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Responsive.spacing(context) * 1.2),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xff0B8F55),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      pdfGenerated = true;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("PDF generated successfully."),
                      ),
                    );
                  },
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text(
                    "Export as PDF",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: Responsive.spacing(context)),

              if (pdfGenerated)
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.padding(context)),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xffE9FFF4),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xff0B8F55),
                            size: 34,
                          ),
                        ),

                        SizedBox(height: 15),

                        Text(
                          "PDF Ready",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          fileName,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),

                        SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Download functionality will be connected later.",
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.download),
                            label: Text("Download PDF"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


