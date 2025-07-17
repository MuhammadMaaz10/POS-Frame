import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/controller/add_invoice_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_list_tile.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class AddInvoicesScreen extends StatelessWidget {
  const AddInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(AddInvoicesController());
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Create New Invoice",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: Colors.white, weight: 500),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          child: GetBuilder<AddInvoicesController>(builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TitleAndInput(
                  controller: controller.invoiceIDController,
                  titletext: "Invoice Number",
                  labeltext: controller.invoiceNumber.value,
                  suffixtext: "Auto Generated",
                  isdisabled: true,
                ),
                16.ht,

                Align(
                  alignment: Alignment.topLeft,
                  child: CustomText(
                    text: "Currency ",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                10.ht,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w,),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(8.r)
                  ),
                  child: DropdownButton<String>(
                    dropdownColor: AppColors.bgClr,
                    isExpanded: true,
                    underline: SizedBox(),
                    value: controller.selectedCurrency.value,
                    items: ['USD', 'ZWG'].map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: CustomText(text:currency,fontWeight: FontWeight.w500,fontSize: 14.sp,),
                      );
                    }).toList(),
                    onChanged: controller.updateSelectedCurrency,
                  ),
                ),

                16.ht,
                TitleAndInput(
                  ontap: () => controller.showCustomerBottomSheet(context),
                  titletext: "Customer",
                  labeltext: "",
                  suffixtext:
                  controller.selectedCustomer.value != null ? "Change" : "",
                  underline: true,
                  secondary: GestureDetector(
                    onTap: () => controller.showCustomerBottomSheet(context),
                    child: Obx(
                          () => controller.selectedCustomer.value == null
                          ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.secondaryClr,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              size: 20.sp,
                              Icons.person_add_alt_1_sharp,
                              color: Colors.white70,
                            ),
                            7.ht,
                            CustomText(
                              text: "Select Customer",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      )
                          : ItemsCustomListTile(

                        leftPadding: 15.w,
                        titleText: controller.selectedCustomer.value!.name,
                        subTitleText:
                        controller.selectedCustomer.value!.email,
                        isTrailing: false,
                      ),
                    ),
                  ),
                ),

                16.ht,

                TitleAndInput(
                  ontap: () => controller.showItemBottomSheet(context),
                  titletext: "Item",
                  labeltext: "",
                  suffixtext: controller.selectedItemsWithQuantity.isNotEmpty ? "Change" : "",
                  underline: true,
                  secondary: GestureDetector(
                    onTap: () => controller.showItemBottomSheet(context),
                    child: Obx(() {
                      if (controller.selectedItemsWithQuantity.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.secondaryClr,
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset(AppImages.itemIcon, height: 16.6.h),
                              7.ht,
                              CustomText(
                                text: "Select Item",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: controller.selectedItemsWithQuantity.entries.map((entry) {
                          final item = entry.key;
                          final qty = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ItemsCustomListTile(
                              imageUrl: null,
                              leftPadding: 10.w,
                              titleText: item.itemName,
                              subTitleText: "${item.itemCategory} • Qty: $qty",
                              amount: item.unitPrice,
                              isTrailing: true,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),

                16.ht,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * 0.44,
                      child: TitleAndInput(
                        suffixIcon: Icons.calendar_month,
                        controller: controller.dateController,
                        titletext: "Invoice Date",
                        labeltext: controller.dateController.text.isEmpty
                            ? "Select Date"
                            : controller.dateController.text,
                        ontap: () => controller.selectDate(context, isInvoiceDate: true),

                      ),
                    ),
                    10.wd,
                    SizedBox(
                      width: size.width * 0.44,
                      child: TitleAndInput(
                        suffixIcon: Icons.calendar_month,
                        controller: controller.dueDateController,
                        titletext: "Due Date",
                        labeltext: controller.dueDateController.text.isEmpty
                            ? "Select Date"
                            : controller.dueDateController.text,
                        ontap: () =>
                            controller.selectDate(context, isInvoiceDate: false),
                      ),
                    ),
                  ],
                ),
                16.ht,
                TitleAndInput(
                  controller: controller.notesController,
                  titletext: "Notes",
                  labeltext: "Enter notes",
                  minLines: 4,
                ),
                16.ht,
                TitleAndInput(
                  controller: controller.addressController,
                  titletext: "Terms and Conditions",
                  labeltext: "Enter terms and conditions",
                  minLines: 4,
                ),
                60.ht,
                Padding(
                  padding: EdgeInsets.only(left: 174.w),
                  child: CustomButton(
                    text: "Generate Invoice",
                    onPressed: () => controller.generateInvoice(),
                  ),
                ),
              ],
            );
          },),
        ),
      ),
    );
  }
}


class TitleAndInput extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? secondary;
  final int? minLines;
  final String titletext;
  final String? suffixtext;
  final String labeltext;
  final bool isdisabled;
  final bool underline;
  IconData? suffixIcon;
  final GestureTapCallback? ontap;

   TitleAndInput({
    super.key,
    required this.titletext,
    this.suffixtext,
    this.suffixIcon,
    required this.labeltext,
    this.isdisabled = false,
    this.secondary,
    this.underline = false,
    this.ontap,
    this.controller,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: titletext,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            GestureDetector(
              onTap: ontap,
              child: CustomText(
                text: suffixtext ?? "",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.smallTextClr,
                decoration:
                    underline ? TextDecoration.underline : TextDecoration.none,
                decorationColor: AppColors.smallTextClr,
              ),
            ),
          ],
        ),
        10.ht,
        secondary ??
            CustomTextField(
              controller: controller!,
              hintText: labeltext,
              keyboardType: TextInputType.text,
              borderColor: Colors.transparent,
              selectedBorderColor: AppColors.buttonClr,
              maxLines: minLines,
              enabled: !isdisabled,
              onTap: ontap,
              suffixIcon: suffixIcon,
            ),
      ],
    );
  }
}
