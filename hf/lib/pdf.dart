import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

Future<void> generateAndPrintPdf({
  required String customerName,
  required String interestRate,
  required String settlementDate,
  required String accountType,
  required List<Map<String, dynamic>> transactions,
  required BuildContext context,
}) async {
  final pdf = pw.Document();

  final dateStamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final fileName = "${customerName.replaceAll(" ", "_")}_$dateStamp.pdf";

  double totalAmount = 0;
  double totalInterest = 0;

  final tableRows = <pw.TableRow>[
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        for (final header in [
          'S.No',
          'Bill Date',
          'Bill No',
          'Bill Amount',
          'Interest Amount',
          'Total Amount'
        ])
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(header,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          )
      ],
    ),
  ];

  int serial = 1;
  for (var txn in transactions) {
    final date = DateTime.parse(txn['date']);
    final billAmount = txn['billamount'] as double;
    final billNo = txn['billno'];

    final settle = DateFormat('yyyy-MM-dd').parse(settlementDate);
    int days = settle.difference(date).inDays;
    double dailyRate = double.parse(interestRate.replaceAll('%', '')) / 100 / 30;
    double interest = billAmount * dailyRate * days;
    double total = billAmount + interest;

    totalAmount += billAmount;
    totalInterest += interest;

    tableRows.add(
      pw.TableRow(
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text("$serial")),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(DateFormat('yyyy-MM-dd').format(date))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(billNo.toString())),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(billAmount.toStringAsFixed(2))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(interest.toStringAsFixed(2))),
          pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(total.toStringAsFixed(2))),
        ],
      ),
    );
    serial++;
  }

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text("Customer Name: $customerName",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 4),
        pw.Text("Interest Rate: $interestRate     Settle Date: $settlementDate     Account Type: $accountType"),
        pw.SizedBox(height: 12),
        pw.Table(border: pw.TableBorder.all(), children: tableRows),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text("Total Bill Amount: ${totalAmount.toStringAsFixed(2)}"),
              pw.Text("Total Interest Amount: ${totalInterest.toStringAsFixed(2)}"),
              pw.Text("Payment Amount: ${(totalAmount + totalInterest).toStringAsFixed(2)}"),
            ])
          ],
        )
      ],
    ),
  );

  await Printing.layoutPdf(
    name: fileName,
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
