import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:intl/intl.dart';

class ProcessedReceiptDetailScreen extends StatelessWidget {
  final ProcessedReceipt receipt;

  const ProcessedReceiptDetailScreen({super.key, required this.receipt});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        centerTitle: false,
        titleSpacing: 0,
        leading: const AppBarBackButton(),
        title: CustomText(
          text: receipt.invoiceNo,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          textAlign: TextAlign.start,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Type', receipt.receiptType),
            _row('Currency', receipt.receiptCurrency),
            if (receipt.receiptGlobalNo != null)
              _row('Receipt global No', '${receipt.receiptGlobalNo}'),
            if (receipt.receiptCounter != null)
              _row('Receipt counter', '${receipt.receiptCounter}'),
            _row('Date', _formatDate(receipt.receiptDate)),
            _row('Tax inclusive', '${receipt.receiptLinesTaxInclusive}'),
            _row('Total', receipt.receiptTotal.toStringAsFixed(2)),
            _row('Tax amount', receipt.receiptTaxAmount.toStringAsFixed(2)),
            _row('Print form', receipt.receiptPrintForm),
            if (receipt.receiptNotes != null && receipt.receiptNotes!.isNotEmpty)
              _row('Notes', receipt.receiptNotes!),
            16.ht,
            const CustomText(
              text: 'Buyer',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              textAlign: TextAlign.start,
            ),
            8.ht,
            _row('Name', receipt.buyerData.buyerRegisterName),
            _row('TIN', receipt.buyerData.buyerTIN),
            if (receipt.buyerData.vatNumber != null &&
                receipt.buyerData.vatNumber!.isNotEmpty)
              _row('VAT', receipt.buyerData.vatNumber!),
            16.ht,
            const CustomText(
              text: 'Items',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              textAlign: TextAlign.start,
            ),
            8.ht,
            ...receipt.receiptLines.map((line) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryClr,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: line.receiptLineName,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        textAlign: TextAlign.start,
                      ),
                      4.ht,
                      CustomText(
                        text:
                            'Qty ${line.receiptLineQuantity.toStringAsFixed(0)} · '
                            '${receipt.receiptCurrency} ${line.receiptLineTotal.toStringAsFixed(2)} · '
                            'Tax ${line.taxPercent.toStringAsFixed(1)}%',
                        fontSize: 12,
                        color: Colors.white70,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              );
            }),
            16.ht,
            const CustomText(
              text: 'Payments',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              textAlign: TextAlign.start,
            ),
            8.ht,
            ...receipt.receiptPayments.map(
              (p) => _row(
                p.moneyTypeCode,
                '${receipt.receiptCurrency} ${p.paymentAmount.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 12,
            color: Colors.white70,
            textAlign: TextAlign.start,
          ),
          4.ht,
          CustomText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
