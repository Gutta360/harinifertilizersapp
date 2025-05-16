import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DownloadCustomersPdfWidget extends StatelessWidget {
  const DownloadCustomersPdfWidget({super.key});

  Future<void> _generateAndDownloadPdf() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('customers').get();

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Customer List')),
            pw.Table.fromTextArray(
              headers: ['ID', 'Surname', 'Name', 'Phone Number'],
              data: snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return [
                  doc.id,
                  data['surname'] ?? '',
                  data['name'] ?? '',
                  data['phonenumber'] ?? '',
                ];
              }).toList(),
            ),
          ],
        ),
      );

      Uint8List bytes = await pdf.save();

      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'customers.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      debugPrint('Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _generateAndDownloadPdf,
        child: const Text('📥 Download Customers as PDF'),
      ),
    );
  }
}
