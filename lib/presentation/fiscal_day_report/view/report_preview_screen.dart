import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_day_report/controller/fiscal_day_report_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

pw.Font? satoshiLight;
pw.Font? satoshiRegular;
pw.Font? satoshiMedium;
pw.Font? satoshiBold;
pw.Font? satoshiBlack;

Future<void> _loadSatoshiFonts() async {
  satoshiLight ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Light.ttf'));
  satoshiRegular ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Regular.ttf'));
  satoshiMedium ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Medium.ttf'));
  satoshiBold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Bold.ttf'));
  satoshiBlack ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Black.ttf'));
}

class ReportPreviewScreen extends StatefulWidget {
  @override
  _ReportPreviewScreenState createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  final controller = Get.find<FiscalDayReportController>();

  Future<void> _shareReport() async {
    try {
      final pdfBytes = await _generateReportPdf();
      await Printing.sharePdf(bytes: pdfBytes, filename: 'fiscal_day_report_${controller.reportModel?.fiscalDayNo ?? "0"}.pdf');
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Could not generate or share PDF: $e');
      }
    }
  }

  String _formatRawDate(String? raw) {
    if (raw == null || raw.isEmpty || raw == "-") return raw ?? "-";
    try {
      if (raw.contains('T')) {
        List<String> parts = raw.split('T');
        String date = parts[0];
        String time = parts[1];
        if (time.contains('.')) {
          time = time.split('.')[0];
        }
        return "$date $time";
      }
      return raw;
    } catch (e) {
      return raw;
    }
  }

  Future<Uint8List> _generateReportPdf() async {
    await _loadSatoshiFonts();
    final pdf = pw.Document();
    final model = controller.reportModel!;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          final regular = pw.TextStyle(fontSize: 7, font: satoshiRegular);
          final bold = pw.TextStyle(fontSize: 8, font: satoshiBold, fontWeight: pw.FontWeight.bold);
          final bigBold = pw.TextStyle(fontSize: 12, font: satoshiBlack ?? satoshiBold, fontWeight: pw.FontWeight.bold);
          final small = pw.TextStyle(fontSize: 6, font: satoshiRegular);

          pw.Widget dashedDivider() => pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              children: List.generate(
                30,
                (index) => pw.Expanded(
                  child: pw.Container(
                    height: 1,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                    color: PdfColors.black,
                  ),
                ),
              ),
            ),
          );

          pw.Widget solidDivider() => pw.Divider(thickness: 1, color: PdfColors.black);

          pw.Widget sectionHeader(String title, {String? iconText}) {
            return pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
              child: pw.Row(
                children: [
                  if (iconText != null) ...[
                    pw.Text(iconText, style: bold),
                    pw.SizedBox(width: 4),
                  ],
                  pw.Text(title, style: bold),
                ],
              ),
            );
          }

          pw.Widget dataRow(String left, String right, {pw.TextStyle? leftStyle, pw.TextStyle? rightStyle}) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(flex: 3, child: pw.Text(left, style: leftStyle ?? regular)),
                  pw.Expanded(flex: 4, child: pw.Text(right, style: rightStyle ?? regular, textAlign: pw.TextAlign.right)),
                ],
              ),
            );
          }

          final items = <pw.Widget>[];

          // Top Dashed Line
          items.add(dashedDivider());

          // Header
          items.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                  ),
                  child: pw.Text('III', style: bigBold), // Simple chart-like icon
                ),
                pw.SizedBox(width: 8),
                pw.Text('FISCAL DAY REPORT', style: bigBold),
              ],
            ),
          );
          items.add(pw.Center(child: pw.Text('Fiscal Day No: ${model.fiscalDayNo ?? ""}', style: bold)));
          items.add(solidDivider());

          // Device Info
          items.add(dataRow('Device ID:', '${model.deviceId ?? ""}'));
          items.add(dataRow('Device Serial No:', '${model.deviceSerialNo ?? ""}'));
          items.add(dataRow('Fiscal Day Opened:', _formatRawDate(model.fiscalDayOpened)));
          items.add(dataRow('Fiscal Day Closed:', _formatRawDate(model.fiscalDayClosed)));
          items.add(dashedDivider());

          // Company Information
          if (model.companyInfo != null) {
            items.add(sectionHeader('COMPANY INFORMATION', iconText: 'H')); // H for House/Building
            items.add(dataRow('Legal Name:', '${model.companyInfo!.legalName ?? ""}'));
            items.add(dataRow('TIN:', '${model.companyInfo!.tin ?? ""}'));
            items.add(dataRow('VAT Number:', '${model.companyInfo!.vatNumber ?? ""}'));
            final address = model.companyInfo!.address;
            if (address != null) {
              items.add(dataRow('Address:', '${address.houseNo ?? ""} ${address.street ?? ""}\n${address.city ?? ""}\n${address.province ?? ""}'));
            }
            items.add(dashedDivider());
          }

          // Daily Totals
          if (model.dailyTotals != null && model.dailyTotals!.isNotEmpty) {
            final currency = model.dailyTotals!.keys.first;
            final totals = model.dailyTotals!.values.first;
            items.add(sectionHeader('DAILY TOTALS ($currency)', iconText: 'S')); // S for Sales
            items.add(dataRow('Net Sales:', '${totals.netSales?.toStringAsFixed(2) ?? "0.00"}'));
            items.add(dataRow('Tax Amount:', '${totals.taxAmount?.toStringAsFixed(2) ?? "0.00"}'));
            items.add(solidDivider());
            items.add(dataRow('Gross Sales:', '${totals.grossSales?.toStringAsFixed(2) ?? "0.00"}', leftStyle: bold, rightStyle: bold));
            items.add(dataRow('Credit Notes:', '${totals.creditNotes?.toStringAsFixed(2) ?? "0.00"}'));
            items.add(dataRow('Debit Notes:', '${totals.debitNotes?.toStringAsFixed(2) ?? "0.00"}'));
            items.add(solidDivider());
          }

          // Tax Breakdown
          if (model.taxBreakdown != null && model.taxBreakdown!.isNotEmpty) {
            final currency = model.taxBreakdown!.keys.first;
            final taxes = model.taxBreakdown!.values.first;
            items.add(sectionHeader('TAX BREAKDOWN ($currency)', iconText: 'T')); // T for Tax
            
            final tableHeader = ['Tax %', 'Tax ID', 'Sales Amount', 'Credit Notes', 'Debit Notes'];
            final tableData = taxes.map((tax) => [
              '${tax.taxPercent ?? "0"}%',
              '${tax.taxID ?? "0"}',
              '${tax.salesAmount?.toStringAsFixed(2) ?? "0.00"}',
              '${tax.creditNoteAmount?.toStringAsFixed(2) ?? "0.00"}',
              '${tax.debitNoteAmount?.toStringAsFixed(2) ?? "0.00"}'
            ]).toList();

            items.add(
              pw.Table.fromTextArray(
                context: context,
                data: [tableHeader, ...tableData],
                headerStyle: bold,
                cellStyle: regular,
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                border: pw.TableBorder.all(width: 0.5),
                cellAlignment: pw.Alignment.centerRight,
                headerAlignment: pw.Alignment.center,
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                },
              ),
            );
            items.add(dashedDivider());
          }

          // Document Counts & Quantity Totals
          if ((model.documentCounts != null && model.documentCounts!.isNotEmpty) || 
              (model.quantityTotals != null && model.quantityTotals!.isNotEmpty)) {
            
            items.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Document Counts
                  if (model.documentCounts != null && model.documentCounts!.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          sectionHeader('DOCUMENT COUNTS', iconText: 'L'), // L for List
                          dataRow('Invoices:', '${model.documentCounts!.values.first.invoices ?? "0"}'),
                          dataRow('Credit Notes:', '${model.documentCounts!.values.first.creditNotes ?? "0"}'),
                          dataRow('Debit Notes:', '${model.documentCounts!.values.first.debitNotes ?? "0"}'),
                        ]
                      )
                    ),
                  
                  // Vertical Dashed Line
                  pw.Container(
                    height: 60,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    child: pw.Column(
                      children: List.generate(10, (index) => pw.Container(width: 1, height: 4, margin: const pw.EdgeInsets.symmetric(vertical: 1), color: PdfColors.black)),
                    ),
                  ),

                  // Right side: Quantity Totals
                  if (model.quantityTotals != null && model.quantityTotals!.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          sectionHeader('QUANTITY TOTALS', iconText: 'Q'), // Q for Quantity
                          dataRow('Total Quantity:', '${model.quantityTotals!.values.first.toStringAsFixed(2)}'),
                        ]
                      )
                    ),
                ]
              )
            );
            items.add(dashedDivider());
          }

          // Payment Methods & Balance Counters
          if ((model.paymentMethods != null && model.paymentMethods!.isNotEmpty) || 
              (model.balanceCounters != null && model.balanceCounters!.isNotEmpty)) {
            
            items.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Payment Methods
                  if (model.paymentMethods != null && model.paymentMethods!.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          sectionHeader('PAYMENT METHODS', iconText: 'P'), // P for Payments
                          ...model.paymentMethods!.values.first.entries.map((e) => dataRow('${e.key}:', e.value.toStringAsFixed(2))),
                          solidDivider(),
                          dataRow('Total:', model.paymentMethods!.values.first.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2), leftStyle: bold, rightStyle: bold),
                        ]
                      )
                    ),
                  
                  // Vertical Dashed Line
                  pw.Container(
                    height: 60,
                    margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                    child: pw.Column(
                      children: List.generate(10, (index) => pw.Container(width: 1, height: 4, margin: const pw.EdgeInsets.symmetric(vertical: 1), color: PdfColors.black)),
                    ),
                  ),

                  // Right side: Balance Counters
                  if (model.balanceCounters != null && model.balanceCounters!.isNotEmpty)
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          sectionHeader('BALANCE COUNTERS', iconText: 'B'), // B for Balance
                          ...model.balanceCounters!.values.first.entries.map((e) => dataRow('${e.key}:', e.value.toStringAsFixed(2))),
                          solidDivider(),
                          dataRow('Total:', model.balanceCounters!.values.first.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2), leftStyle: bold, rightStyle: bold),
                        ]
                      )
                    ),
                ]
              )
            );
            items.add(dashedDivider());
          }

          // Documents Table
          if (model.documents != null && model.documents!.isNotEmpty) {
            items.add(sectionHeader('DOCUMENTS', iconText: 'D')); // D for Documents
            
            final docHeader = ['Type', 'Invoice No', 'Date', 'Total', 'Tax', 'Global No'];
            final docData = model.documents!.map((doc) => [
              '${doc.type ?? ""}',
              '${doc.invoiceNo ?? ""}',
              '${doc.date?.split(' ')[0] ?? ""}', // Date only to fit
              '${doc.total?.toStringAsFixed(2) ?? "0.00"}',
              '${doc.taxAmount?.toStringAsFixed(2) ?? "0.00"}',
              '${doc.globalNo ?? ""}'
            ]).toList();

            items.add(
              pw.Table.fromTextArray(
                context: context,
                data: [docHeader, ...docData],
                headerStyle: bold,
                cellStyle: small, // Use small font for document table to fit columns
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                border: pw.TableBorder.all(width: 0.5),
                cellAlignment: pw.Alignment.centerRight,
                headerAlignment: pw.Alignment.center,
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.2),
                  1: const pw.FlexColumnWidth(2.5),
                  2: const pw.FlexColumnWidth(1.8),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1),
                },
              ),
            );
          }

          items.add(pw.SizedBox(height: 12));
          items.add(pw.Center(child: pw.Text('--- End of Report ---', style: regular)));
          items.add(dashedDivider());

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: items,
          );
        },
      ),
    );
    return pdf.save();
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              color: Colors.black26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16.sp, color: Colors.black87),
            8.wd,
          ],
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String left, String right, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(left, style: TextStyle(color: Colors.black87, fontSize: 13.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w500))),
          Expanded(flex: 4, child: Text(right, textAlign: TextAlign.right, style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildBorderedTable(List<String> headers, List<List<String>> rows, {List<int>? flexValues}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            child: Row(
              children: List.generate(headers.length, (i) => Expanded(
                flex: flexValues != null ? flexValues[i] : 1,
                child: Text(headers[i], textAlign: i == 0 ? TextAlign.left : TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: Colors.black)),
              )),
            ),
          ),
          ...rows.map((row) => Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
            child: Row(
              children: List.generate(row.length, (i) => Expanded(
                flex: flexValues != null ? flexValues[i] : 1,
                child: Text(row[i], textAlign: i == 0 ? TextAlign.left : TextAlign.right, style: TextStyle(fontSize: 11.sp, color: Colors.black87)),
              )),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = controller.reportModel;
    if (model == null) {
      return Scaffold(
        backgroundColor: AppColors.bgClr,
        appBar: AppBar(backgroundColor: AppColors.bgClr),
        body: Center(child: Text("No data available", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: 'REPORT PREVIEW',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDashedDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                          child: Icon(Icons.bar_chart, size: 24.sp, color: Colors.black),
                        ),
                        12.wd,
                        Text('FISCAL DAY REPORT', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.black)),
                      ],
                    ),
                    Center(child: Text('Fiscal Day No: ${model.fiscalDayNo ?? ""}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black))),
                    Divider(thickness: 2, color: Colors.black, height: 20.h),

                    _buildDataRow('Device ID:', '${model.deviceId ?? ""}'),
                    _buildDataRow('Device Serial No:', '${model.deviceSerialNo ?? ""}'),
                    _buildDataRow('Fiscal Day Opened:', _formatRawDate(model.fiscalDayOpened)),
                    _buildDataRow('Fiscal Day Closed:', _formatRawDate(model.fiscalDayClosed)),
                    _buildDashedDivider(),

                    if (model.companyInfo != null) ...[
                      _buildSectionHeader('COMPANY INFORMATION', icon: Icons.business),
                      _buildDataRow('Legal Name:', '${model.companyInfo!.legalName ?? ""}'),
                      _buildDataRow('TIN:', '${model.companyInfo!.tin ?? ""}'),
                      _buildDataRow('VAT Number:', '${model.companyInfo!.vatNumber ?? ""}'),
                      if (model.companyInfo!.address != null)
                        _buildDataRow('Address:', '${model.companyInfo!.address!.houseNo ?? ""} ${model.companyInfo!.address!.street ?? ""}\n${model.companyInfo!.address!.city ?? ""}\n${model.companyInfo!.address!.province ?? ""}'),
                      _buildDashedDivider(),
                    ],

                    if (model.dailyTotals != null && model.dailyTotals!.isNotEmpty) ...[
                      _buildSectionHeader('DAILY TOTALS (${model.dailyTotals!.keys.first})', icon: Icons.analytics),
                      _buildDataRow('Net Sales:', '${model.dailyTotals!.values.first.netSales?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildDataRow('Tax Amount:', '${model.dailyTotals!.values.first.taxAmount?.toStringAsFixed(2) ?? "0.00"}'),
                      Divider(color: Colors.black26),
                      _buildDataRow('Gross Sales:', '${model.dailyTotals!.values.first.grossSales?.toStringAsFixed(2) ?? "0.00"}', isBold: true),
                      _buildDataRow('Credit Notes:', '${model.dailyTotals!.values.first.creditNotes?.toStringAsFixed(2) ?? "0.00"}'),
                      _buildDataRow('Debit Notes:', '${model.dailyTotals!.values.first.debitNotes?.toStringAsFixed(2) ?? "0.00"}'),
                      Divider(color: Colors.black26),
                    ],

                    if (model.taxBreakdown != null && model.taxBreakdown!.isNotEmpty) ...[
                      _buildSectionHeader('TAX BREAKDOWN (${model.taxBreakdown!.keys.first})', icon: Icons.pie_chart),
                      _buildBorderedTable(
                        ['Tax %', 'Tax ID', 'Sales', 'Credit', 'Debit'],
                        model.taxBreakdown!.values.first.map((t) => [
                          '${t.taxPercent ?? 0}%',
                          '${t.taxID ?? 0}',
                          '${t.salesAmount?.toStringAsFixed(2) ?? "0.00"}',
                          '${t.creditNoteAmount?.toStringAsFixed(2) ?? "0.00"}',
                          '${t.debitNoteAmount?.toStringAsFixed(2) ?? "0.00"}'
                        ]).toList(),
                        flexValues: [2, 2, 3, 3, 3]
                      ),
                      _buildDashedDivider(),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.documentCounts != null && model.documentCounts!.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader('DOC COUNTS', icon: Icons.list_alt),
                                _buildDataRow('Invoices:', '${model.documentCounts!.values.first.invoices ?? "0"}'),
                                _buildDataRow('Credit:', '${model.documentCounts!.values.first.creditNotes ?? "0"}'),
                                _buildDataRow('Debit:', '${model.documentCounts!.values.first.debitNotes ?? "0"}'),
                              ],
                            )
                          ),
                        Container(width: 1, height: 100.h, color: Colors.black12, margin: EdgeInsets.symmetric(horizontal: 8.w)),
                        if (model.quantityTotals != null && model.quantityTotals!.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader('QTY TOTALS', icon: Icons.inventory_2),
                                _buildDataRow('Total Qty:', '${model.quantityTotals!.values.first.toStringAsFixed(2)}'),
                              ],
                            )
                          ),
                      ],
                    ),
                    _buildDashedDivider(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (model.paymentMethods != null && model.paymentMethods!.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader('PAYMENTS', icon: Icons.payments),
                                ...model.paymentMethods!.values.first.entries.map((e) => _buildDataRow('${e.key}:', e.value.toStringAsFixed(2))),
                                Divider(),
                                _buildDataRow('Total:', model.paymentMethods!.values.first.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2), isBold: true),
                              ],
                            )
                          ),
                        Container(width: 1, height: 100.h, color: Colors.black12, margin: EdgeInsets.symmetric(horizontal: 8.w)),
                        if (model.balanceCounters != null && model.balanceCounters!.isNotEmpty)
                          Expanded(
                            child: Column(
                              children: [
                                _buildSectionHeader('BALANCES', icon: Icons.account_balance_wallet),
                                ...model.balanceCounters!.values.first.entries.map((e) => _buildDataRow('${e.key}:', e.value.toStringAsFixed(2))),
                                Divider(),
                                _buildDataRow('Total:', model.balanceCounters!.values.first.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2), isBold: true),
                              ],
                            )
                          ),
                      ],
                    ),
                    _buildDashedDivider(),

                    if (model.documents != null && model.documents!.isNotEmpty) ...[
                      _buildSectionHeader('DOCUMENTS', icon: Icons.description),
                      _buildBorderedTable(
                        ['Type', 'Invoice No', 'Total', 'Tax'],
                        model.documents!.map((doc) => [
                          '${doc.type ?? ""}',
                          '${doc.invoiceNo ?? ""}',
                          '${doc.total?.toStringAsFixed(2) ?? "0.00"}',
                          '${doc.taxAmount?.toStringAsFixed(2) ?? "0.00"}'
                        ]).toList(),
                        flexValues: [3, 5, 3, 3]
                      ),
                    ],

                    20.ht,
                    Center(child: Text('--- End of Report ---', style: TextStyle(color: Colors.black54, fontSize: 12.sp))),
                    _buildDashedDivider(),
                    20.ht,
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: _shareReport,
                  icon: Icon(Icons.share, color: Colors.white),
                  label: Text('Share Report PDF', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgClr,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
