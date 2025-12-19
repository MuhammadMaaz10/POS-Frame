import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/invoice_pdf_generation_screen/model/invoice_pdf_preview_model.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../local_storage/company_model.dart';
import '../../constants/app_constants.dart';

import '../../widgets/custom_text.dart';

pw.Font? satoshiLight;
pw.Font? satoshiRegular;
pw.Font? satoshiMedium;
pw.Font? satoshiBold;
pw.Font? satoshiBlack;

Future<void> loadFonts() async {
  satoshiLight ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Light.ttf'));
  satoshiRegular ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Regular.ttf'));
  satoshiMedium ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Medium.ttf'));
  satoshiBold ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Bold.ttf'));
  satoshiBlack ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Black.ttf'));
}

class CustomText2 extends StatelessWidget {
  final String text;
  final TextStyle? style;
  TextAlign? textAlign;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;

  CustomText2(this.text, {this.style, this.textAlign, this.fontSize, this.fontWeight, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 5,
      textAlign: textAlign ?? TextAlign.center,
      style: GoogleFonts.robotoMono(
        textStyle: style ??
            TextStyle(
              color: color ?? Colors.black54,
              fontSize: fontSize ?? 14.sp,
              fontWeight: fontWeight ?? FontWeight.w400,
            ),
      ),
    );
  }
}

class InvoiceScreenPdfView extends StatefulWidget {
  final invoicePdfPreviewModel previewModel;
  final String qrUrl;

  InvoiceScreenPdfView({Key? key, required this.previewModel, required this.qrUrl}) : super(key: key);

  @override
  _InvoiceScreenPdfViewState createState() => _InvoiceScreenPdfViewState();
}

class _InvoiceScreenPdfViewState extends State<InvoiceScreenPdfView> {
  int totalQuantity = 0;
  CompanyModel? companyData;
  bool isLoadingCompany = true;
  
  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }
  
  Future<void> _loadCompanyData() async {
    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      
      if (username != null) {
        final box = await Hive.openBox<CompanyModel>('companies_$username');
        if (box.isNotEmpty) {
          setState(() {
            companyData = box.values.first;
            isLoadingCompany = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Error loading company data: $e');
    }
    setState(() {
      isLoadingCompany = false;
    });
  }
  
  String _getCompanyAddress() {
    if (companyData == null) return 'N/A';
    List<String> parts = [];
    if (companyData!.address.isNotEmpty) parts.add(companyData!.address);
    if (companyData!.city.isNotEmpty) parts.add(companyData!.city);
    if (companyData!.province.isNotEmpty) parts.add(companyData!.province);
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  // String _getInvoiceNumber() {
  //   // Use receiptGlobalNo if available, otherwise use invoiceNo
  //   if (widget.previewModel.receiptGlobalNo != null) {
  //     return '${widget.previewModel.receiptGlobalNo}';
  //   }
  //   return widget.previewModel.invoiceNo ?? 'N/A';
  // }
  
  String _getFiscalDayNumber() {
    return AppConstant.fiscalDayNumber.isNotEmpty && AppConstant.fiscalDayNumber != "null"
        ? AppConstant.fiscalDayNumber
        : 'N/A';
  }
  
  String _getDeviceId() {
    return fiscalDeviceID.isNotEmpty ? fiscalDeviceID : 'N/A';
  }

  @override
  Widget build(BuildContext context) {

    double totalNet = 0;
    double totalVat = 0;
    double totalGross = 0;

    for (var item in widget.previewModel.receiptLines!) {
      final gross = item.receiptLineTotal?.toDouble() ?? 0;
      final vat = calculateTax(gross, item.taxPercent?.toDouble() ?? 0);
      final net = gross - vat;

      totalNet += net;
      totalVat += vat;
      totalGross += gross;
    }


    // ✅ calculating totalQuantity once at the top
    totalQuantity = widget.previewModel.receiptLines
        ?.fold<int>(0, (sum, line) => sum + (line.receiptLineQuantity ?? 0)) ??
        0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: 'FISCAL TAX INVOICE',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, weight: 500),
        ),
      ),
      body: isLoadingCompany
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: CustomText2('FISCAL TAX INVOICE',
                          style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    8.ht,
                    // Company TIN - you may need to add this to CompanyModel
                    // CustomText2('TIN: ${widget.previewModel.buyerData!.buyerTIN}'),
                    // Center(child: CustomText2('VAT No: ${widget.previewModel.buyerData?.buyerVAT ?? ''}')), // Add VAT number to CompanyModel if needed

                    CustomText2('TIN: ${companyData?.tinNumber ?? ''}'),
                    Center(child: CustomText2('VAT No: ${companyData?.vatNumber ?? ''}')), // Add VAT number to CompanyModel if needed
                    Center(child: CustomText2('${companyData?.companyName ?? 'N/A'}')),

                    5.ht,
                    Center(
                      child: CustomText2(
                        _getCompanyAddress(),
                      ),
                    ),
                    Center(child: CustomText2('${companyData?.email ?? 'N/A'}')),
                    // Company email - add to CompanyModel if needed, or remove if not available
                    Center(child: CustomText2('Contact: ${companyData?.contactNumber ?? 'N/A'}')),
                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,
                    Center(
                      child: CustomText2('FISCAL TAX INVOICE',
                          style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    /// Buyer details
                    CustomText2('Buyer', color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
                    CustomText2('${widget.previewModel.buyerData!.buyerRegisterName}'),
                    // Buyer email - you may need to add this to customer model or buyer data
                    if (widget.previewModel.buyerData?.buyerAddress != null) ...[
                      5.ht,
                      Center(
                        child: CustomText2(
                          "${widget.previewModel.buyerData!.buyerAddress!.houseNumber ?? ''}, "
                              "${widget.previewModel.buyerData!.buyerAddress!.street ?? ''}, "
                              "${widget.previewModel.buyerData!.buyerAddress!.city ?? ''}, "
                              "${widget.previewModel.buyerData!.buyerAddress!.province ?? ''}",
                        ),
                      ),
                    ],
                    CustomText2('TIN: ${widget.previewModel.buyerData!.buyerTIN}'),
                    CustomText2('VAT No: ${widget.previewModel.buyerData?.buyerVAT ?? ''}'),

                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          CustomText2('Invoice No: ${widget.previewModel.invoiceNo}'),
                        ]),
                        CustomText2('Fiscal day No: ${_getFiscalDayNumber()}'),
                        CustomText2('Customer reference No: ${widget.previewModel.buyerData!.buyerTIN}', textAlign: TextAlign.start),
                        CustomText2('Device ID: ${_getDeviceId()}', textAlign: TextAlign.start),
                        CustomText2('Date: ${_formatDate(DateTime.now())}', textAlign: TextAlign.start),
                      ],
                    ),

                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText2('Description', color: Colors.black, fontWeight: FontWeight.w600),
                        CustomText2('Amount', color: Colors.black, fontWeight: FontWeight.w600),
                      ],
                    ),
                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.previewModel.receiptLines!.length,
                      itemBuilder: (context, index) {
                        final data = widget.previewModel.receiptLines![index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200.w,
                              child: CustomText2(textAlign: TextAlign.start, '${data.receiptLineName} x ${data.receiptLineQuantity}'),
                            ),
                            CustomText2("${data.receiptLineTotal?.toStringAsFixed(2)}"),
                          ],
                        );
                      },
                    ),

                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          CustomText2('Total ${widget.previewModel.receiptCurrency}',
                              color: Colors.black, fontWeight: FontWeight.w600),
                          CustomText2('${widget.previewModel.receiptTotal?.toStringAsFixed(2)}',
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ]),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          CustomText2('${widget.previewModel.receiptCurrency} Cash'),
                          CustomText2('${widget.previewModel.receiptTotal?.toStringAsFixed(2)}'),
                        ]),
                      ],
                    ),

                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    /// Number of Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText2('Number of Items', color: Colors.black, fontWeight: FontWeight.w600),
                        CustomText2('${totalQuantity.toString()}', color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ],
                    ),

                    4.ht,
                    const Divider(thickness: 1, color: Colors.black),
                    4.ht,

                    // ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   reverse: true,
                    //   itemCount: widget.previewModel.receiptLines!.length,
                    //   itemBuilder: (context, index) {
                    //     final data = widget.previewModel.receiptLines![index];
                    //
                    //     double tax = calculateTax(data.receiptLineTotal!.toDouble(), data.taxPercent!.toDouble());
                    //     final netAmount = (data.receiptLineTotal ?? 0) - tax;
                    //
                    //     return Column(
                    //       children: [
                    //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    //            CustomText2('Net Amount ', textAlign: TextAlign.start),
                    //           CustomText2(netAmount.toStringAsFixed(2)),
                    //         ]),
                    //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    //           CustomText2('VAT (${data.taxPercent})', textAlign: TextAlign.start),
                    //           CustomText2(tax.toStringAsFixed(2)),
                    //         ]),
                    //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    //            CustomText2('Gross Amount', textAlign: TextAlign.start),
                    //           CustomText2('${data.receiptLineTotal?.toStringAsFixed(2)}'),
                    //         ]),
                    //
                    //         const Divider(thickness: 1, color: Colors.black),
                    //         4.ht,
                    //       ],
                    //     );
                    //   },
                    // ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText2('Total Net Amount'),
                            CustomText2(totalNet.toStringAsFixed(2)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText2('Total VAT'),
                            CustomText2(totalVat.toStringAsFixed(2)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText2('Total Gross Amount'),
                            CustomText2(totalGross.toStringAsFixed(2)),
                          ],
                        ),
                        const Divider(thickness: 1, color: Colors.black),
                        4.ht,
                      ],
                    ),



                    5.ht,
                     Center(child: CustomText2('Invoice is issued after purchasing goods')),
                    5.ht,

                    /// QR code
                    Center(
                      child: QrImageView(
                        data: widget.qrUrl,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        errorStateBuilder: (context, error) {
                          return Text(
                            'Error generating QR code: $error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                     Center(child: CustomText2('You can verify this receipt manually at')),

                    GestureDetector(
                      onTap: () => _launchUrl(widget.qrUrl),
                      child: CustomText2(
                        "https://fdmstest.zimra.co.zw/",
                        color: Colors.blue,
                      ),
                    ),

                    CustomText2(
                      "Verification Code: \n${getVerificationCode(widget.qrUrl)}",
                      fontWeight: FontWeight.w600,
                      // style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                    const SizedBox(height: 6),
                    CustomText2(
                      "Fiscalised by Frame Inc",
                      // style: TextStyle(fontSize: 10, color: Colors.white),
                    ),

                    /// Clickable link
                    GestureDetector(
                      onTap: () => _launchUrl("https://www.frame.co.zw"),
                      child: CustomText2(
                        "www.frame.co.zw",
                          color: Colors.blue,
                      ),
                    ),
                    16.ht,
                    CustomButton(text: "Share as Pdf", onPressed: () => generateInvoicePdf(context)),
                    46.ht,
                  ],
                ),
              ),
            ),
    );
  }

  // helper function
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  String getVerificationCode(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['ReceiptQrData'] ?? url.split('/').last;
    } catch (_) {
      return url.split('/').last;
    }
  }


  Future<void> generateInvoicePdf(BuildContext context) async {
    await loadFonts();
    final pdf = pw.Document();

    // Generate QR image bytes
    final qrCode = await QrPainter(
      data: widget.qrUrl,
      version: QrVersions.auto,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: false,
    ).toImageData(200);



    double totalNet = 0.0;
    double totalVat = 0.0;
    double totalGross = 0.0;

    for (var line in widget.previewModel.receiptLines ?? []) {
      final gross = (line.receiptLineTotal ?? 0).toDouble();
      final vat = calculateTax(gross, (line.taxPercent ?? 0).toDouble());
      final net = gross - vat;

      totalNet += net;
      totalVat += vat;
      totalGross += gross;
    }


    /// Updated PDF generation with real data
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Center(
                child: pw.Text(
                  'FISCAL TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: 10, font: satoshiBold, fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 4),

              // Company Information
              if (companyData != null) ...[
                pw.Center(
                  child: pw.Text(
                    "TIN: ${companyData!.tinNumber ?? ''}",
                    style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    "VAT No: ${companyData!.vatNumber ?? ''}",
                    style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    companyData!.companyName,
                    style: pw.TextStyle(fontSize: 9, font: satoshiBold),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    _getCompanyAddress(),
                    style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                if (companyData!.email.isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      'Email: ${companyData!.email}',
                      style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                    ),
                  ),
                if (companyData!.contactNumber.isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      'Contact: ${companyData!.contactNumber}',
                      style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                    ),
                  ),

              ],

              pw.Divider(thickness: 0.5),

              // BUYER DETAILS
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text('Buyer', style: pw.TextStyle(fontSize: 9, font: satoshiMedium))),
              pw.Center(child: pw.Text(widget.previewModel.buyerData?.buyerRegisterName ?? '', style: pw.TextStyle(fontSize: 8, font: satoshiRegular))),
              if (widget.previewModel.buyerData?.buyerAddress != null)
                pw.Center(
                  child: pw.Text(
                    '${widget.previewModel.buyerData?.buyerAddress?.houseNumber ?? ''}, '
                        '${widget.previewModel.buyerData?.buyerAddress?.street ?? ''}, '
                        '${widget.previewModel.buyerData?.buyerAddress?.city ?? ''}, '
                        '${widget.previewModel.buyerData?.buyerAddress?.province ?? ''}',
                    style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.Center(child: pw.Text('TIN: ${widget.previewModel.buyerData?.buyerTIN ?? ''}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular))),
              pw.Center(child: pw.Text('VAT No: ${widget.previewModel.buyerData?.buyerVAT ?? ''}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular))),
              pw.Divider(thickness: 0.5),

              // INVOICE INFO - Using real data
              pw.SizedBox(height: 4),
              pw.Text('Invoice Info:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice No: ${widget.previewModel.invoiceNo}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                ],
              ),
              pw.Text('Fiscal day No: ${_getFiscalDayNumber()}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              pw.Text('Customer reference No: ${widget.previewModel.buyerData?.buyerTIN ?? ''}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              pw.Text('Device ID: ${_getDeviceId()}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              pw.Text('Date: ${_formatDate(DateTime.now())}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              pw.Divider(thickness: 0.5),

              // ITEMS
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Description', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
                  pw.Text('Amount', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
                ],
              ),
              pw.Divider(thickness: 0.5),

              pw.ListView.builder(
                itemCount: widget.previewModel.receiptLines?.length ?? 0,
                itemBuilder: (context, index) {
                  final data = widget.previewModel.receiptLines![index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${data.receiptLineName} x ${data.receiptLineQuantity}',
                          style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                        ),
                      ),
                      pw.Text('${(data.receiptLineTotal ?? 0).toStringAsFixed(2)} ${widget.previewModel.receiptCurrency}',
                          style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                    ],
                  );
                },
              ),

              pw.Divider(thickness: 0.5),

              // TOTALS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total ${widget.previewModel.receiptCurrency}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
                  pw.Text('${widget.previewModel.receiptTotal?.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${widget.previewModel.receiptCurrency} Cash', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                  pw.Text('${widget.previewModel.receiptTotal?.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                ],
              ),
              pw.Divider(thickness: 0.5),

              // NUMBER OF ITEMS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Number of Items', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: satoshiBold)),
                  pw.Text(
                    '${widget.previewModel.receiptLines?.fold<int>(0, (sum, line) => sum + (line.receiptLineQuantity ?? 0)) ?? 0}',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: satoshiBold),
                  ),
                ],
              ),
              pw.Divider(thickness: 0.5),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total Net Amount", style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                  pw.Text(totalNet.toStringAsFixed(2), style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                ],
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total VAT", style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                  pw.Text(totalVat.toStringAsFixed(2), style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                ],
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total Gross Amount", style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                  pw.Text(totalGross.toStringAsFixed(2), style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
                ],
              ),
              pw.Divider(thickness: 0.5),


              // ...(widget.previewModel.receiptLines ?? []).map((data) {
              //   final tax = calculateTax((data.receiptLineTotal ?? 0).toDouble(), (data.taxPercent ?? 0).toDouble());
              //   final netAmount = (data.receiptLineTotal ?? 0) - tax;
              //   return pw.Column(
              //     crossAxisAlignment: pw.CrossAxisAlignment.start,
              //     children: [
              //       pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              //         pw.Text('Net Amount', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //         pw.Text(netAmount.toStringAsFixed(2), style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //       ]),
              //       pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              //         pw.Text('VAT (${data.taxPercent ?? 0}%)', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //         pw.Text(tax.toStringAsFixed(2), style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //       ]),
              //       pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              //         pw.Text('Gross Amount', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //         pw.Text('${data.receiptLineTotal}', style: pw.TextStyle(fontSize: 8, font: satoshiRegular)),
              //       ]),
              //       pw.Divider(thickness: 0.5),
              //     ],
              //   );
              // }).toList(),

              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text('Invoice is issued after purchasing goods', style: pw.TextStyle(fontSize: 8, font: satoshiRegular))),
              pw.SizedBox(height: 8),

              // QR
              if (qrCode != null)
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(qrCode.buffer.asUint8List()),
                    width: 80,
                    height: 80,
                  ),
                ),
              pw.SizedBox(height: 4),
              pw.Center(
                child:  pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 8),
                    pw.Text("Verify Manually at:",
                        style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                        textAlign: pw.TextAlign.center),
                    pw.UrlLink(
                      destination: widget.qrUrl,
                      child: pw.Text(
                        "https://fdmstest.zimra.co.zw/",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Text("Verification Code: ${getVerificationCode(widget.qrUrl)}",
                        style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 6),
                    pw.Text("Fiscalised by Frame Inc",
                        style: pw.TextStyle(fontSize: 8, font: satoshiRegular),
                        textAlign: pw.TextAlign.center),
                    pw.UrlLink(
                      destination: "https://www.frame.co.zw/",
                      child: pw.Text(
                        "www.frame.co.zw",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.blue,
                          decoration: pw.TextDecoration.underline,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),


            ],
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice.pdf');
    await file.writeAsBytes(pdfBytes);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: AppColors.bgClr,
            title: CustomText(
              text: 'Invoice PDF preview',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            leading: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.arrow_back, color: Colors.white, weight: 500),
            ),
          ),
          body: PdfPreview(
            shouldRepaint: false,
            canDebug: false,
            dynamicLayout: false,
            actionBarTheme: const PdfActionBarTheme(height: 60, backgroundColor: AppColors.bgClr),
            useActions: false, // hide built-in (theme/format/share/print) toggles
            allowPrinting: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await Printing.sharePdf(bytes: pdfBytes, filename: 'invoice.pdf');
                },
              ),

              // IconButton(
              //   icon: const Icon(CupertinoIcons.printer),
              //   onPressed: () {
              //     // 👉 Open Bluetooth search screen and print like earlier code
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => BluetoothPrintPage(
              //           previewModel: widget.previewModel,
              //           qrUrl: widget.qrUrl,
              //         ),
              //       ),
              //     );
              //   },
              // ),
              //
              // IconButton(
              //   icon: const Icon(CupertinoIcons.printer),
              //   onPressed: () async {
              //     await Printing.layoutPdf(
              //       onLayout: (PdfPageFormat format) async => pdfBytes,
              //     );
              //   },
              // ),

            ],
            allowSharing: false,
            build: (format) => pdfBytes,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
        ),
      ),
    );
  }

  double calculateTax(double netAmount, double taxPercentage) {
    if (taxPercentage == 0) return 0.0;
    return ((netAmount * taxPercentage) / (100 + taxPercentage));
  }
}

extension ParseStringToDouble on String {
  double parseDouble() => double.tryParse(this) ?? 0.0;
}
