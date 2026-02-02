import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StoreInvoicePreviewScreen extends StatefulWidget {
  StoreInvoicePreviewScreen({super.key});

  @override
  State<StoreInvoicePreviewScreen> createState() =>
      _StoreInvoicePreviewScreenState();
}

class _StoreInvoicePreviewScreenState extends State<StoreInvoicePreviewScreen> {
  final controller = Get.find<StoreInvoicesController>();
  final TextEditingController tenderController = TextEditingController();

  double _parseAmount(String raw) {
    // allow comma separators
    final cleaned = raw.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
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

