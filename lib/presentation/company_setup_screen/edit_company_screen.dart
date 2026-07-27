import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/company_setup_screen/controller/company_setup_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../local_storage/company_model.dart';

class EditCompanyScreen extends StatefulWidget {
  const EditCompanyScreen({super.key});

  @override
  _EditCompanyScreenState createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final CompanySetupController companySetupController = Get.put(CompanySetupController());
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final company = await companySetupController.loadCompany();
    if (company != null) {
      setState(() {
        companySetupController.companyNameController.text = company.companyName;
        companySetupController.cityController.text = company.city;
        companySetupController.provinceController.text = company.province;
        companySetupController.addressController.text = company.address;
        companySetupController.contactController.text = company.contactNumber;
        companySetupController.emailController.text = company.email;
        companySetupController.tinNumberController.text = company.tinNumber ?? '';
        companySetupController.vatNumberController.text = company.vatNumber ?? '';
        companySetupController.selectedClientNumber = company.clientNumber;
        if (company.logoPath.isNotEmpty) {
          companySetupController.logoImagePath = company.logoPath;
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateCompany() {
    if (_formKey.currentState!.validate()) {
      companySetupController.updateCompany(
        CompanyModel(
          logoPath: companySetupController.logoImagePath,
          companyName: companySetupController.companyNameController.text.trim(),
          city: companySetupController.cityController.text.trim(),
          province: companySetupController.provinceController.text.trim(),
          address: companySetupController.addressController.text.trim(),
          contactNumber: companySetupController.contactController.text.trim(),
          email: companySetupController.emailController.text.trim(),
          tinNumber: companySetupController.tinNumberController.text.trim().isEmpty 
              ? null 
              : companySetupController.tinNumberController.text.trim(),
          vatNumber: companySetupController.vatNumberController.text.trim().isEmpty 
              ? null 
              : companySetupController.vatNumberController.text.trim(),
          clientNumber: companySetupController.selectedClientNumber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgClr,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        leading: const AppBarBackButton(),
        backgroundColor: AppColors.bgClr,
        elevation: 0,
        title: const CustomText(
          text: "Edit Company",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: GetBuilder<CompanySetupController>(
          builder: (controller) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.ht,
                    const CustomText(
                      text: "Edit Company Profile",
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    10.ht,
                    CustomText(
                      text: "Update your company information.",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    20.ht,
                    CustomText(
                      text: "Company Logo",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    10.ht,
                    DottedBorder(
                      dashPattern: const [10, 5],
                      radius: Radius.circular(30.r),
                      color: const Color(0xFF343A40),
                      child: InkWell(
                        onTap: () async {
                          await controller.pickImageFromGallery();
                        },
                        child: controller.logoImagePath == ''
                            ? Container(
                          height: 147.h,
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF172349),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.uploadIcon,
                                height: 36.h,
                                width: 33.w,
                              ),
                              6.ht,
                              const Text(
                                "Upload Logo",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              5.ht,
                              const Text(
                                "Max 10 MB in .jpg/.jpeg/.png format",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          height: 147.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF172349),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Image.file(
                            File(controller.logoImagePath),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    16.ht,

                    CustomText(
                      text: "Company Name",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      controller: controller.companyNameController,
                      hintText: 'Company Name*',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: (value) {
                        if (value == null || value
                            .trim()
                            .isEmpty) {
                          return 'Company Name is required';
                        }
                        if (value
                            .trim()
                            .length < 2) {
                          return 'Company Name must be at least 2 characters';
                        }
                        return null;
                      }
                      ),
                    16.ht,
                    CustomText(
                      text: "Client Number",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryClr,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButton<int>(
                        dropdownColor: AppColors.bgClr,
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: AppColors.white,
                        iconDisabledColor: Colors.white38,
                        value: controller.selectedClientNumber,
                        items: List.generate(100, (index) => index + 1).map((clientNum) {
                          return DropdownMenuItem<int>(
                            value: clientNum,
                            child: CustomText(
                              text: clientNum.toString(),
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          );
                        }).toList(),
                        onChanged: null, // Disabled - client number cannot be changed after initial setup
                      ),
                    ),
                    16.ht,
                    CustomText(
                      text: "Business Location",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "City",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            5.ht,
                            SizedBox(
                              width: 173.w,
                              child: CustomTextField(
                                controller: controller.cityController,
                                hintText: 'City*',
                                borderColor: Colors.transparent,
                                selectedBorderColor: AppColors.buttonClr,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'City is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        Column( crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "Province",
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            5.ht,
                            SizedBox(
                              width: 173.w,
                              child: CustomTextField(
                                controller: controller.provinceController,
                                hintText: 'Province*',
                                borderColor: Colors.transparent,
                                selectedBorderColor: AppColors.buttonClr,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Province is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    10.ht,

                    CustomText(
                      text: "Company Address",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      keyboardType: TextInputType.streetAddress,
                      controller: controller.addressController,
                      hintText: 'Company Address',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                    ),
                    10.ht,

                    CustomText(
                      text: "Contact Number",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      controller: controller.contactController,
                      hintText: 'Contact Number',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                    ),
                    10.ht,

                    CustomText(
                      text: "Company Email",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.emailController,
                      hintText: 'Company Email',
                      prefixIcon: Icons.email_outlined,
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                    ),
                    10.ht,

                    CustomText(
                      text: "TIN Number",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      keyboardType: TextInputType.number,
                      controller: controller.tinNumberController,
                      hintText: 'TIN Number',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'TIN Number is required';
                        }

                        final trimmed = value.trim();

                        if (trimmed.length != 10) {
                          return 'TIN Number must be exactly 10 characters';
                        }

                        return null;
                      },
                    ),
                    10.ht,

                    CustomText(
                      text: "VAT Number",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    5.ht,
                    CustomTextField(
                      keyboardType: TextInputType.number,
                      controller: controller.vatNumberController,
                      hintText: 'VAT Number',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'VAT Number is required';
                        }

                        final trimmed = value.trim();

                        if (trimmed.length != 9) {
                          return 'VAT Number must be exactly 9 characters';
                        }
                        return null;
                      },
                    ),
                    62.ht,
                    CustomButton(
                      text: 'Update',
                      onPressed: _updateCompany,
                      color: AppColors.buttonClr,
                    ),
                    20.ht,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
