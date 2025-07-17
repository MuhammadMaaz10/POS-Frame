import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/controller/add_item_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final controller = Get.put(AddItemController());

  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Add New Item",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: AppColors.white, weight: 500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 0.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.ht,
                CustomText(
                  text: "HS Code",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.hsCodeController,
                  hintText: "12345678",
                  keyboardType: TextInputType.number,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 1,
                  validator: controller.validateHsCode,
                ),
                16.ht,
                CustomText(
                  text: "Item Details",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.nameController,
                  hintText: "Item Name",
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 1,
                  validator: controller.validateName,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.categoryController,
                  hintText: "Item Category",
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 1,
                  validator: controller.validateCategory,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.descriptionController,
                  hintText: "Item Description",
                  keyboardType: TextInputType.text,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 4,
                  // validator: controller.validateDescription,
                ),
                16.ht,
                CustomText(
                  text: "Unit Price",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.priceController,
                  hintText: "Enter Price",
                  keyboardType: TextInputType.number,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 1,
                  validator: controller.validatePrice,
                ),
                16.ht,
                CustomText(
                  text: "VAT Category",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                GestureDetector(
                  onTap: () => controller.showTaxGroupBottomSheet(context),
                  child: CustomTextField(
                    controller: controller.vatCategoryNameController,
                    hintText: "Select Tax Group",
                    keyboardType: TextInputType.text,
                    borderColor: Colors.transparent,
                    selectedBorderColor: AppColors.buttonClr,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => controller.showTaxGroupBottomSheet(context),
                    maxLines: 1,
                    enabled: false,
                    validator: controller.validateVatCategory,
                  ),
                ),
                104.ht,
                Padding(
                  padding: EdgeInsets.only(left: 174.w),
                  child: CustomButton(
                    text: "Save Item",
                    onPressed: () => controller.saveItem(),
                    isLoading: controller.isLoading.value,
                  ),
                ),
                20.ht,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


