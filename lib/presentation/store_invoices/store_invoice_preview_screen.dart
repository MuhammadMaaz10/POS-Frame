import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoice_api_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/utils/invoice_number_generator.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

class StoreInvoicePreviewScreen extends StatefulWidget {
  StoreInvoicePreviewScreen({super.key});

  @override
  State<StoreInvoicePreviewScreen> createState() =>
      _StoreInvoicePreviewScreenState();
}

class _StoreInvoicePreviewScreenState extends State<StoreInvoicePreviewScreen> {
  final controller = Get.find<StoreInvoicesController>();
  final storeInvoiceApi = Get.find<StoreInvoiceApiController>();
  final TextEditingController tenderController = TextEditingController();

  double _parseAmount(String raw) {
    // allow comma separators
    final cleaned = raw.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Generates store invoice as PDF and opens the system share sheet (Print, WhatsApp, etc.).
  Future<void> _shareInvoice() async {
    try {
      final pdfBytes = await _generateStoreInvoicePdf();
      await Printing.sharePdf(bytes: pdfBytes, filename: 'invoice.pdf');
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Could not generate or share PDF: $e');
      }
    }
  }

  Future<Uint8List> _generateStoreInvoicePdf() async {
    await _loadSatoshiFonts();
    final pdf = pw.Document();
    // Match the on-screen Store Invoice preview layout: narrow receipt format,
    // tax line under each item, and include tender + remaining/change.
    final currency = controller.selectedCurrency.value;
    final grandTotal = controller.calculateGrandTotal();
    final totalTax = controller.calculateTotalTax();
    final totalNet = controller.calculateTotalNet();
    final totalQty = controller.getTotalQuantity();
    final tendered = _parseAmount(tenderController.text);
    final diff = tendered - grandTotal;
    final byId = {for (final it in controller.itemList) it.id: it};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          final regular = pw.TextStyle(fontSize: 8, font: satoshiRegular);
          final bold = pw.TextStyle(fontSize: 9, font: satoshiBold, fontWeight: pw.FontWeight.bold);
          final bigBold = pw.TextStyle(fontSize: 11, font: satoshiBlack ?? satoshiBold, fontWeight: pw.FontWeight.bold);

          pw.Widget row2(String left, String right, {pw.TextStyle? leftStyle, pw.TextStyle? rightStyle}) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(left, style: leftStyle ?? regular)),
                pw.SizedBox(width: 4),
                pw.Text(right, style: rightStyle ?? regular),
              ],
            );
          }

          pw.Widget divider() => pw.Divider(thickness: 0.5);

          final items = <pw.Widget>[];

          // Header
          items.add(pw.Center(child: pw.Text('STORE INVOICE', style: bigBold)));
          items.add(pw.SizedBox(height: 4));

          // Company section (matches preview)
          if (controller.companyData != null) {
            items.add(pw.Text('TIN: ${controller.companyData!.tinNumber ?? ''}', style: regular));
            items.add(pw.Center(child: pw.Text('VAT No: ${controller.companyData!.vatNumber ?? ''}', style: regular)));
            items.add(pw.Center(child: pw.Text(controller.companyData!.companyName, style: bold)));
            items.add(pw.Center(child: pw.Text(_getCompanyAddress(), style: regular)));
            if (controller.companyData!.email.isNotEmpty) {
              items.add(pw.Center(child: pw.Text(controller.companyData!.email, style: regular)));
            }
            if (controller.companyData!.contactNumber.isNotEmpty) {
              items.add(pw.Center(child: pw.Text('Contact: ${controller.companyData!.contactNumber}', style: regular)));
            }
          }

          items.add(pw.SizedBox(height: 4));
          items.add(divider());
          items.add(pw.SizedBox(height: 4));

          // Invoice info
          items.add(pw.Center(child: pw.Text('Invoice Info', style: bold)));
          items.add(pw.SizedBox(height: 2));
          items.add(pw.Text('Date: ${_formatDate(DateTime.now())}', style: regular));
          items.add(pw.Text('Currency: $currency', style: regular));

          items.add(pw.SizedBox(height: 4));
          items.add(divider());
          items.add(pw.SizedBox(height: 4));

          // Items header
          items.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Item Name', style: bold),
                pw.Text('Qty', style: bold),
                pw.Text('Amount', style: bold),
              ],
            ),
          );
          items.add(pw.SizedBox(height: 2));
          items.add(divider());
          items.add(pw.SizedBox(height: 2));

          // Items list (with tax line like preview)
          for (final entry in controller.selectedQuantities.entries) {
            final item = byId[entry.key];
            if (item == null) continue;
            final qty = entry.value;
            final itemTotal = controller.calculateItemTotal(item, quantity: qty);
            final itemTax = controller.calculateItemTax(item, quantity: qty);

            items.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.itemName, style: regular, maxLines: 3),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'Tax ${item.taxGroup.toStringAsFixed(1)}%',
                          style: pw.TextStyle(fontSize: 7, font: satoshiRegular),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.topCenter,
                      child: pw.Text('$qty', style: regular),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('$currency ${itemTotal.toStringAsFixed(2)}', style: regular),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          '$currency ${itemTax.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 7, font: satoshiRegular),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            items.add(pw.SizedBox(height: 4));
            items.add(pw.Divider(thickness: 0.3));
            items.add(pw.SizedBox(height: 4));
          }

          // Number of items
          items.add(row2('Number of Items', '$totalQty', leftStyle: bold, rightStyle: bold));
          items.add(pw.SizedBox(height: 4));
          items.add(divider());
          items.add(pw.SizedBox(height: 4));

          // Totals section (same labels/order as preview)
          items.add(row2('Total Net Amount', '$currency ${totalNet.toStringAsFixed(2)}'));
          items.add(pw.SizedBox(height: 2));
          items.add(row2('Total Tax', '$currency ${totalTax.toStringAsFixed(2)}'));
          items.add(pw.SizedBox(height: 4));
          items.add(divider());
          items.add(pw.SizedBox(height: 4));
          items.add(row2('Grand Total', '$currency ${grandTotal.toStringAsFixed(2)}', leftStyle: bigBold, rightStyle: bigBold));

          items.add(pw.SizedBox(height: 4));
          items.add(divider());
          items.add(pw.SizedBox(height: 6));

          // Tender + remaining/change (to match preview)
          items.add(pw.Text('Tender Amount', style: bold));
          items.add(pw.SizedBox(height: 2));
          items.add(row2('Tendered', '$currency ${tendered.toStringAsFixed(2)}'));
          items.add(pw.SizedBox(height: 2));
          items.add(
            row2(
              diff >= 0 ? 'Change' : 'Remaining',
              '$currency ${diff.abs().toStringAsFixed(2)}',
              leftStyle: bold,
              rightStyle: pw.TextStyle(fontSize: 9, font: pw.Font.courierBold(), fontWeight: pw.FontWeight.bold),
            ),
          );

          items.add(pw.SizedBox(height: 8));

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: items,
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  void dispose() {
    tenderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: 'STORE INVOICE',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, weight: 500),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingCompany.value) {
          return Center(child: CircularProgressIndicator());
        }

        final grandTotal = controller.calculateGrandTotal();
        final tendered = _parseAmount(tenderController.text);
        final diff = tendered - grandTotal;

        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Invoice Title
              CustomText2(
                'STORE INVOICE',
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.ht,

              // Company Details Section
              if (controller.companyData != null) ...[
                CustomText2('TIN: ${controller.companyData!.tinNumber ?? ''}', color: Colors.black),
                Center(
                  child: CustomText2('VAT No: ${controller.companyData!.vatNumber ?? ''}', color: Colors.black),
                ),
                Center(
                  child: CustomText2(
                    controller.companyData!.companyName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                5.ht,
                Center(
                  child: CustomText2(_getCompanyAddress(), color: Colors.black),
                ),
                Center(
                  child: CustomText2(controller.companyData!.email.isNotEmpty ? controller.companyData!.email : 'N/A', color: Colors.black),
                ),
                Center(
                  child: CustomText2('Contact: ${controller.companyData!.contactNumber.isNotEmpty ? controller.companyData!.contactNumber : 'N/A'}', color: Colors.black),
                ),
              ],

              8.ht,
              Divider(thickness: 1, color: Colors.black),
              8.ht,

              // Invoice Info
              CustomText2(
                'Invoice Info',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              4.ht,
              CustomText2('Date: ${_formatDate(DateTime.now())}', color: Colors.black),
              CustomText2('Currency: ${controller.selectedCurrency.value}', color: Colors.black),
              8.ht,
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next invoice no. (on submit)',
                      style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                    ),
                    4.ht,
                    Get.isRegistered<ProcessedReceiptsController>()
                        ? Obx(() {
                            final list = Get.find<ProcessedReceiptsController>()
                                .receipts
                                .toList();
                            return Text(
                              generateNextInvoiceForSubmit(
                                original: null,
                                apiReceipts: list,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            );
                          })
                        : Text(
                            generateNextInvoiceForSubmit(
                              original: null,
                              apiReceipts: null,
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                  ],
                ),
              ),
              8.ht,
              Divider(thickness: 1, color: Colors.black),
              8.ht,

              // Items Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText2(
                    'Item Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText2(
                    'Qty',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText2(
                    'Amount',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              // Items List
              ...(() {
                final byId = {for (final it in controller.itemList) it.id: it};
                return controller.selectedQuantities.entries
                    .map((entry) {
                      final item = byId[entry.key];
                      if (item == null) return null;
                      final quantity = entry.value;
                      final itemTotal =
                          controller.calculateItemTotal(item, quantity: quantity);
                      final itemTax =
                          controller.calculateItemTax(item, quantity: quantity);

                      return Column(
                        children: [
                    // Item Name, Quantity, Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText2(
                                item.itemName,
                                textAlign: TextAlign.start,
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                              2.ht,
                              CustomText2(
                                'Tax ${_getTaxPercentageText(item)}%',
                                textAlign: TextAlign.start,
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomText2(
                            quantity.toString(),
                            textAlign: TextAlign.center,
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomText2(
                                '${controller.selectedCurrency.value} ${itemTotal.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                              2.ht,
                              CustomText2(
                                '${controller.selectedCurrency.value} ${itemTax.toStringAsFixed(2)}',
                                textAlign: TextAlign.end,
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    8.ht,
                    Divider(thickness: 0.5, color: Colors.grey.shade300),
                    8.ht,
                        ],
                      );
                    })
                    .whereType<Widget>()
                    .toList();
              })(),

              // Number of Items (show above totals)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText2(
                    'Number of Items',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  CustomText2(
                    '${controller.getTotalQuantity()}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              8.ht,
              Divider(thickness: 1, color: Colors.black),
              8.ht,

              // Totals Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2(
                        'Total Net Amount',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      CustomText2(
                        '${controller.selectedCurrency.value} ${controller.calculateTotalNet().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  4.ht,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2(
                        'Total Tax',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      CustomText2(
                        '${controller.selectedCurrency.value} ${controller.calculateTotalTax().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  8.ht,
                  Divider(thickness: 1, color: Colors.black),
                  8.ht,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      CustomText2(
                        '${controller.selectedCurrency.value} ${grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  8.ht,
                  Divider(thickness: 1, color: Colors.black),
                  8.ht,

                  // Tender amount input + change calculation
                  CustomText2(
                    'Tender Amount',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  6.ht,
                  TextField(
                    controller: tenderController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: '${controller.selectedCurrency.value} ',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                    ),
                    style: GoogleFonts.robotoMono(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  10.ht,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2(
                        diff >= 0 ? 'Change' : 'Remaining',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      CustomText2(
                        '${controller.selectedCurrency.value} ${diff.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: diff >= 0 ? Colors.black : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  16.ht,
                  // Submit store invoice (fields data) via separate API provider
                  Obx(() {
                    final isSubmitting = storeInvoiceApi.isSubmitting.value;
                    final error = storeInvoiceApi.submitError.value;
                    final success = storeInvoiceApi.lastSubmitSuccess.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (error != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (success)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              'Receipt submitted successfully.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 44.h,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    storeInvoiceApi.clearSubmitState();
                                    final ok = await storeInvoiceApi.submitStoreInvoice();
                                    if (ok && mounted) {
                                      storeInvoiceApi.clearSubmitState();
                                      controller.clearSelection();
                                      if (!Get.isRegistered<
                                          ProcessedReceiptsController>()) {
                                        Get.put(
                                          ProcessedReceiptsController(),
                                          permanent: true,
                                        );
                                      }
                                      final prc =
                                          Get.find<ProcessedReceiptsController>();
                                      await prc.refreshReceipts();
                                      Get.back();
                                      // List GET can briefly lag behind POST; retry once.
                                      Future<void>.delayed(
                                        const Duration(milliseconds: 800),
                                        () {
                                          if (Get.isRegistered<
                                              ProcessedReceiptsController>()) {
                                            Get.find<ProcessedReceiptsController>()
                                                .refreshReceipts();
                                          }
                                        },
                                      );
                                      Get.snackbar(
                                        'Success',
                                        'Store invoice submitted.',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppColors.bgClr,
                                        colorText: AppColors.white,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                            ),
                            child: isSubmitting
                                ? SizedBox(
                                    width: 22.w,
                                    height: 22.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Submit receipt'),
                          ),
                        ),
                        12.ht,
                        // Share invoice option
                        SizedBox(
                          height: 44.h,
                          child: OutlinedButton.icon(
                            onPressed: _shareInvoice,
                            icon: Icon(Icons.share, size: 20.sp, color: Colors.black87),
                            label: Text(
                              'Share invoice',
                              style: TextStyle(color: Colors.black87, fontSize: 14.sp),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              20.ht,
            ],
            ),
          ),
        );
      }),
    );
  }

  String _getCompanyAddress() {
    if (controller.companyData == null) return 'N/A';
    List<String> parts = [];
    if (controller.companyData!.address.isNotEmpty) {
      parts.add(controller.companyData!.address);
    }
    if (controller.companyData!.city.isNotEmpty) {
      parts.add(controller.companyData!.city);
    }
    if (controller.companyData!.province.isNotEmpty) {
      parts.add(controller.companyData!.province);
    }
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getTaxPercentageText(dynamic item) {
    // InventoryItem.taxGroup is already a percentage.
    if (item != null && item.taxGroup is num) {
      final v = (item.taxGroup as num).toDouble();
      // Keep it simple like "15.0" / "0.0"
      return v.toStringAsFixed(1);
    }
    return '0.0';
  }
}

class CustomText2 extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  CustomText2(
    this.text, {
    this.style,
    this.textAlign,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 5,
      textAlign: textAlign ?? TextAlign.center,
      style: GoogleFonts.robotoMono(
        textStyle: style ??
            TextStyle(
              color: color ?? Colors.black,
              fontSize: fontSize ?? 14.sp,
              fontWeight: fontWeight ?? FontWeight.w400,
            ),
      ),
    );
  }
}

