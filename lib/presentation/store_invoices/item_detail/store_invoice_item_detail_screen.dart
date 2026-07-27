import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/inventory_item.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

class StoreInvoiceItemDetailScreen extends StatelessWidget {
  final InventoryItem item;
  final String currency;

  const StoreInvoiceItemDetailScreen({
    super.key,
    required this.item,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: const CustomText(
          text: 'Item Details',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: const AppBarBackButton(color: AppColors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.secondaryClr,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: item.itemName,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  textAlign: TextAlign.start,
                ),
                10.ht,
                _detailRow('Item Code', item.itemCode),
                10.ht,
                _detailRow('Description', item.description.isNotEmpty ? item.description : 'N/A'),
                10.ht,
                _detailRow('Available Qty', item.availableQuantity.toStringAsFixed(2)),
                10.ht,
                _detailRow('Tax %', '${item.taxGroup.toStringAsFixed(2)}%'),
                10.ht,
                _detailRow('Price', '$currency ${item.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110.w,
          child: CustomText(
            text: label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          child: CustomText(
            text: value,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}


