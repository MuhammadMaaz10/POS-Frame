import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/controller/add_customer_controller.dart';
import 'package:get/get.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';

import '../../widgets/custom_textfield.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final controller = Get.put(CustomerController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Add New Customer",
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
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.ht,
                Center(
                  child: GestureDetector(
                    onTap: () => controller.showImagePickerDialog(context),
                    child: Obx(
                          () => CircleAvatar(
                            backgroundColor: Color(0xFF172349),
                        backgroundImage: controller.selectedImage.value != null
                            ? FileImage(controller.selectedImage.value!)
                            : AssetImage("AppImages.demo") as ImageProvider,
                        radius: 50.w,
                        child: controller.selectedImage.value == null
                            ? Icon(
                          Icons.camera_alt,
                          color: Colors.white70,
                          size: 30.w,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),
                16.ht,
                CustomText(
                  text: "Customer Name",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.nameController,
                  hintText: "Enter Name",
                  keyboardType: TextInputType.name,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: controller.validateName,
                ),
                16.ht,
                // CustomText(
                //   text: "Customer Contact",
                //   fontSize: 14,
                //   fontWeight: FontWeight.w500,
                //   color: Colors.white70,
                // ),
                // 10.ht,
                CustomText(
                  text: "Email",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.emailController,
                  hintText: "Enter email",
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: controller.validateEmail,
                ),
                16.ht,
                CustomText(
                  text: "Phone",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.phoneController,
                  hintText: "Enter phone number",
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: controller.validatePhone,
                ),
                16.ht,
                CustomText(
                  text: "Address",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                10.ht,
                CustomTextField(
                  controller: controller.addressController,
                  hintText: "Enter address",
                  keyboardType: TextInputType.streetAddress,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  maxLines: 2,
                  validator: controller.validateAddress,
                ),
                147.ht,
                Padding(
                  padding: EdgeInsets.only(left: 174.w),
                  child: CustomButton(
                    text: "Save",
                    onPressed: () => controller.saveCustomer(),
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

