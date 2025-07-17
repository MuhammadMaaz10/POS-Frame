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

class EditInvoicesScreen extends StatelessWidget {
  const EditInvoicesScreen({super.key});

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
          text: "Edit Invoice",
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
                  controller: controller.editInvoiceIDController,
                  titletext: "Invoice Number",
                  labeltext: controller.editInvoiceNumber.value,
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
                    value: controller.editSelectedCurrency.value,
                    items: ['USD', 'ZWG'].map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: CustomText(text:currency,fontWeight: FontWeight.w500,fontSize: 14.sp,),
                      );
                    }).toList(),
                    onChanged: controller.editUpdateSelectedCurrency,
                  ),
                ),

                16.ht,


                TitleAndInput(
                  ontap: () => controller.showEditCustomerBottomSheet(context),
                  titletext: "Customer",
                  labeltext: "",
                  suffixtext: controller.editSelectedCustomer.value != null ? "Change" : "",
                  underline: true,
                  secondary: GestureDetector(
                    onTap: () => controller.showEditCustomerBottomSheet(context),
                    child: Obx(
                          () => controller.editSelectedCustomer.value == null
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
                        leftPadding: 0.w,
                        titleText: controller.editSelectedCustomer.value!.name,
                        subTitleText:
                        controller.editSelectedCustomer.value!.email,
                        isTrailing: false,
                      ),
                    ),
                  ),
                ),

                16.ht,

                TitleAndInput(
                  ontap: () => controller.showEditItemBottomSheet(context),
                  titletext: "Item",
                  labeltext: "",
                  suffixtext:
                  controller.editSelectedItem.value != null ? "Change" : "",
                  underline: true,
                  secondary: GestureDetector(
                    onTap: () => controller.showEditItemBottomSheet(context),
                    child: Obx(
                            () => controller.editSelectedItem.value == null
                            ? Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.secondaryClr,
                          ),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                AppImages.itemIcon,
                                height: 16.6.h,
                              ),
                              7.ht,
                              CustomText(
                                text: "Select Item",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        )
                            : Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 0.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.secondaryClr,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.editSelectedItem.length,
                            itemBuilder: (context, index) {
                              var item = controller.editSelectedItem[index];
                              // var invoiceTotal = num.parse(item.quantity.toString()) * num.parse(item.price);
                              return ItemsCustomListTile(
                                // tileColor: AppColors.redClr,
                                imageUrl: null,
                                leftPadding: 0.w,
                                titleText: item.name,
                                subTitleText: "${item.category.toString()} • Qty: ${item.quantity}",
                                amount: double.tryParse(item.price),
                                isTrailing: true,
                              );
                            },
                          ),
                        )


                      // : ItemsCustomListTile(
                      //     imageUrl: null,
                      //     leftPadding: 10.w,
                      //     titleText: controller.editSelectedItem.value!.name,
                      //     subTitleText: controller.editSelectedItem.value!.category,
                      //     amount: double.tryParse(controller.editSelectedItem.value!.price),
                      //     isTrailing: true,
                      //   ),
                    ),
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
                        controller: controller.editDateController,
                        titletext: "Invoice Date",
                        labeltext: controller.editDateController.text.isEmpty
                            ? "Select Date"
                            : controller.editDateController.text,
                        ontap: () => controller.selectDate(context, isInvoiceDate: true),

                      ),
                    ),
                    10.wd,
                    SizedBox(
                      width: size.width * 0.44,
                      child: TitleAndInput(
                        suffixIcon: Icons.calendar_month,
                        controller: controller.editDueDateController,
                        titletext: "Due Date",
                        labeltext: controller.editDueDateController.text.isEmpty
                            ? "Select Date"
                            : controller.editDueDateController.text,
                        ontap: () =>
                            controller.selectDate(context, isInvoiceDate: false),
                      ),
                    ),
                  ],
                ),
                16.ht,
                TitleAndInput(
                  controller: controller.editNotesController,
                  titletext: "Notes",
                  labeltext: "Enter notes",
                  minLines: 4,
                ),
                16.ht,
                TitleAndInput(
                  controller: controller.editAddressController,
                  titletext: "Terms and Conditions",
                  labeltext: "Enter terms and conditions",
                  minLines: 4,
                ),
                60.ht,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: CustomButton(
                        text: "Delete",
                        onPressed: () {
                          controller.deleteInvoice();
                        },
                        // isLoading: controller.isLoading.value,
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      child: CustomButton(
                        text: "Save",
                        onPressed: () {
                          print("selected Items length ----> ${controller.editSelectedItem.length}");
                          controller.saveEditedInvoice();
                        },
                        // isLoading: controller.isLoading.value,
                      ),
                    ),
                  ],
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

