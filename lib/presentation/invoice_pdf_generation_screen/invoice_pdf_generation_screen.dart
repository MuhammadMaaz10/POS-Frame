import 'dart:io';
import 'dart:typed_data';

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
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/custom_text.dart';

late final pw.Font satoshiLight;
late final pw.Font satoshiRegular;
late final pw.Font satoshiMedium;
late final pw.Font satoshiBold;
late final pw.Font satoshiBlack;

Future<void> loadFonts() async {
  satoshiLight = pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Light.ttf'));
  satoshiRegular = pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Regular.ttf'));
  satoshiMedium = pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Medium.ttf'));
  satoshiBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Bold.ttf'));
  satoshiBlack = pw.Font.ttf(await rootBundle.load('assets/fonts/Satoshi-Black.ttf'));
}

class CustomText2 extends StatelessWidget {
  final String text;
  final TextStyle? style;
  TextAlign? textAlign;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;

  CustomText2(this.text,
      {this.style, this.textAlign, this.fontSize, this.fontWeight, this.color});

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
                fontWeight: fontWeight ?? FontWeight.w400),
      ),
    );
  }
}

class InvoiceScreenPdfView extends StatefulWidget {
  final invoicePdfPreviewModel previewModel;
  String qrUrl = "";
  InvoiceScreenPdfView({Key? key, required this.previewModel,required this.qrUrl}) : super(key: key);

  @override
  _InvoiceScreenPdfViewState createState() => _InvoiceScreenPdfViewState();
}

class _InvoiceScreenPdfViewState extends State<InvoiceScreenPdfView> {

  int totalQuantity = 0;


  @override
  Widget build(BuildContext context) {
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
          child: Icon(Icons.arrow_back, color: Colors.white, weight: 500),
        ),
      ),
      // appBar: AppBar(
      //   title: CustomText(
      //       text: 'FISCAL TAX INVOICE',
      //       fontSize: 18,
      //       color: Colors.black,
      //       fontWeight: FontWeight.bold),
      //   backgroundColor: Colors.grey[200],
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CustomText2('Test Account',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
              8.ht,
              Center(child: CustomText2('TIN: ${widget.previewModel.buyerData!.buyerTIN}')),
              Center(child: CustomText2('VAT No: ')),
              5.ht,
              // Center(child: CustomText2('Downtown location')),
              Center(
                  child: CustomText2(
                    "${widget.previewModel.buyerData!.buyerAddress!.houseNumber.toString()}, ${widget.previewModel.buyerData!.buyerAddress!.street.toString()}, ${widget.previewModel.buyerData!.buyerAddress!.city.toString()}, ${widget.previewModel.buyerData!.buyerAddress!.province.toString()}",
                      // 'Test Corporation Branch 1 \n22, Byo Street, Bulawayo, Bulawayo'
                  )),
              Center(child: CustomText2('zimbra@email.com')),
              Center(child: CustomText2('(0242) 758 891-5')),
              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,
              Center(
                  child: CustomText2('FISCAL TAX INVOICE',
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold))),
              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              /// Buyer details
              CustomText2(
                'Buyer',
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              CustomText2('${widget.previewModel.buyerData!.buyerRegisterName}'),
              CustomText2('TIN: ${widget.previewModel.buyerData!.buyerTIN}'),
              CustomText2('VAT No: '),

              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2('Invoice No: 15/451'),
                      CustomText2('Fiscal day No: 45'),
                    ],
                  ),
                  CustomText2('Customer reference No: ${widget.previewModel.invoiceNo}',textAlign: TextAlign.start,),
                  CustomText2('Device Serial No: mobiletest',textAlign: TextAlign.start,),
                  CustomText2('Device ID: ',textAlign: TextAlign.start,),
                  CustomText2('Date: ',textAlign: TextAlign.start,),
                ],
              ),

              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText2(
                    'Description',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText2(
                    'Amount',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.previewModel.receiptLines!.length,
                itemBuilder: (context, index) {
                  var data = widget.previewModel.receiptLines![index];
                  totalQuantity += data.receiptLineQuantity ?? 0;
                  print("total quantity ----> ${totalQuantity}");
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 200.w,
                        child: CustomText2(
                            textAlign: TextAlign.start,
                            '${data.receiptLineName} x ${data.receiptLineQuantity}'),
                      ),
                      CustomText2("${data.receiptLineTotal}"),
                    ],
                  );
                },
              ),

              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2('Total ${widget.previewModel.receiptCurrency}',color: Colors.black,
                        fontWeight: FontWeight.w600,),
                      CustomText2('${widget.previewModel.receiptTotal}',color: Colors.black,
                        fontWeight: FontWeight.w600,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText2('${widget.previewModel.receiptCurrency} Cash'),
                      CustomText2('${widget.previewModel.receiptTotal}'),
                    ],
                  ),


              ],),



              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,


              /// Number of Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText2('Number of Items',color: Colors.black,
                    fontWeight: FontWeight.w600,),
                  CustomText2('${totalQuantity}',color: Colors.black,fontSize: 16.sp,
                    fontWeight: FontWeight.w600,),
                ],
              ),


              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,
              Divider(thickness: 1, color: Colors.black),
              4.ht,


              ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: widget.previewModel.receiptLines!.length,
                itemBuilder: (context, index) {
                  var data = widget.previewModel.receiptLines![index];
                  double calculateTax(double netAmount, double taxPercentage) {
                    if (taxPercentage == 0) return 0.0;
                    return ((netAmount * taxPercentage) / (100 + taxPercentage))
                        .toStringAsFixed(2)
                        .parseDouble();
                  }

                  double tax = calculateTax(data.receiptLineTotal!.toDouble(), data.taxPercent!.toDouble()); // netAmount = 1000, tax% = 17
                  print("Tax: $tax"); // Output: 145.3

                  var netAmount = data.receiptLineTotal! - tax;
                  return Column(
                    children: [
                      Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText2('Net Amount ',textAlign: TextAlign.start,),
                          CustomText2('${netAmount}'),
                        ],
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText2('VAT (${data.taxPercent})',textAlign: TextAlign.start,),
                          CustomText2('${tax}'),
                        ],
                      ),
                      Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText2('Gross Amount',textAlign: TextAlign.start,),
                          CustomText2('${data.receiptLineTotal}'),
                        ],
                      ),

                      Divider(thickness: 1, color: Colors.black),
                      4.ht,
                    ],
                  );
                },
              ),



              5.ht,
              Center(
                  child:
                      CustomText2('Invoice is issued after purchasing goods')),
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
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),

              // Text(
              //   'QR URL: ${widget.qrUrl}',
              //   style: TextStyle(fontSize: 16,color: Colors.black),
              //   textAlign: TextAlign.center,
              // ),

              // Center(
              //   child: Container(
              //     width: 100,
              //     height: 100,
              //     color: Colors.grey,
              //     child: CustomText2('QR Code Placeholder'),
              //   ),
              // ),
              // SizedBox(height: 8),
              // Center(
              //     child: CustomText2('Verification code: 4CB8-E276-6333-0417')),
              SizedBox(height: 8),
              Center(
                child: CustomText2(
                    'You can verify this receipt manually at https://receipt.zimra.org/'),
              ),
              16.ht,
              CustomButton(text: "Share as Pdf", onPressed: () => generateInvoicePdf(context),),
              46.ht,
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => generateInvoicePdf(context),
      //   child: Icon(Icons.picture_as_pdf),
      // ),
    );
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              pw.Center(
                child: pw.Text(
                  'FISCAL TAX INVOICE',
                  style: pw.TextStyle(fontSize: 20, font: satoshiBold ,fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text("TIN: ${widget.previewModel.buyerData?.buyerTIN ?? ''}")),
              pw.Center(child: pw.Text(
                  '${widget.previewModel.buyerData?.buyerAddress?.houseNumber ?? ''}, '
                      '${widget.previewModel.buyerData?.buyerAddress?.street ?? ''}, '
                      '${widget.previewModel.buyerData?.buyerAddress?.city ?? ''}, '
                      '${widget.previewModel.buyerData?.buyerAddress?.province ?? ''}')),
              pw.Center(child: pw.Text('Email: zimbra@email.com',style: pw.TextStyle(font: satoshiBold),)),
              pw.Center(child: pw.Text('Phone: (0242) 758 891-5')),
              pw.Divider(thickness: 1),

              // ---------------- BUYER DETAILS ----------------
              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text('Buyer', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal)), ),
              pw.Center(child: pw.Text(widget.previewModel.buyerData?.buyerRegisterName ?? ''), ),
              pw.Center(child: pw.Text('TIN: ${widget.previewModel.buyerData?.buyerTIN ?? ''}'),),
              pw.Center(child: pw.Text('VAT No: '),),

              pw.Divider(thickness: 1),

              // ---------------- INVOICE INFO ----------------
              pw.SizedBox(height: 8),
              pw.Text('Invoice Info:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice No: ${widget.previewModel.invoiceNo}'),
                  pw.Text('Fiscal day No: 45'),
                ],
              ),
              pw.Text('Customer reference No: ${widget.previewModel.invoiceNo}'),
              pw.Text('Device Serial No: mobiletest'),
              pw.Text('Date: ${DateTime.now()}'),
              pw.Divider(thickness: 1),

              // ---------------- ITEMS LIST ----------------
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(thickness: 1),

              pw.ListView.builder(
                itemCount: widget.previewModel.receiptLines?.length ?? 0,
                itemBuilder: (context, index) {
                  final data = widget.previewModel.receiptLines![index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('${data.receiptLineName} x ${data.receiptLineQuantity}')),
                      pw.Text('${data.receiptLineTotal} ${widget.previewModel.receiptCurrency}'),
                    ],
                  );
                },
              ),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // ---------------- TOTAL ----------------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total ${widget.previewModel.receiptCurrency}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${widget.previewModel.receiptTotal}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${widget.previewModel.receiptCurrency} Cash'),
                  pw.Text('${widget.previewModel.receiptTotal}'),
                ],
              ),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // ---------------- NUMBER OF ITEMS ----------------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Number of Items',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '${widget.previewModel.receiptLines?.fold<int>(0, (sum, line) => sum + (line.receiptLineQuantity ?? 0)) ?? 0}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.Divider(thickness: 1),
              pw.SizedBox(height: 8),

              // ---------------- TAX CALCULATION ----------------
              ...widget.previewModel.receiptLines!.map((data) {
                double tax = calculateTax(
                  data.receiptLineTotal!.toDouble(),
                  data.taxPercent!.toDouble(),
                );
                double netAmount = (data.receiptLineTotal ?? 0) - tax;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Net Amount'),
                        pw.Text('${netAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('VAT (${data.taxPercent}%)'),
                        pw.Text('${tax.toStringAsFixed(2)}'),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Gross Amount'),
                        pw.Text('${data.receiptLineTotal}'),
                      ],
                    ),
                    pw.Divider(thickness: 1),
                  ],
                );
              }),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text('Invoice is issued after purchasing goods'),
              ),

              pw.SizedBox(height: 16),

              // ---------------- QR CODE ----------------
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(qrCode!.buffer.asUint8List()),
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('Verify at https://receipt.zimra.org/'),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to temp directory
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice.pdf');
    await file.writeAsBytes(bytes);

    // Preview and Share
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('PDF Preview'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await Share.shareXFiles([XFile(file.path)], text: 'Fiscal Tax Invoice');
                },
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => bytes,
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