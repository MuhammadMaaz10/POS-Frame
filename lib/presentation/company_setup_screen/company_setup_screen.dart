import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/company_setup_screen/controller/company_setup_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../local_storage/company_model.dart';

class CompanySetupScreen extends StatelessWidget {
  CompanySetupScreen({super.key});

  final CompanySetupController companySetupController =
  Get.put(CompanySetupController());
  final _formKey = GlobalKey<FormState>();

  void _createCompany() {
    if (_formKey.currentState!.validate()) {
      // if (companySetupController.logoImagePath.isEmpty) {
      //   Get.snackbar(
      //     'Error',
      //     'Please upload a company logo',
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }
      companySetupController.saveCompany(
        CompanyModel(
          logoPath: companySetupController.logoImagePath,
          companyName: companySetupController.companyNameController.text.trim(),
          city: companySetupController.cityController.text.trim(),
          province: companySetupController.provinceController.text.trim(),
          address: companySetupController.addressController.text.trim(),
          contactNumber: companySetupController.contactController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppColors.bgClr,
        elevation: 0,
      ),
      body: SafeArea(
        child: GetBuilder(
          init: CompanySetupController(),
          builder: (_) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    30.ht,
                    CustomText(
                      text: "Company Setup",
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    10.ht,
                    CustomText(
                      text: "Please fill in your details to complete profile.",
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
                      dashPattern: [10, 5],
                      radius: Radius.circular(30.r),
                      color: Color(0xFF343A40),
                      child: InkWell(
                        onTap: () async {
                          final path = await companySetupController.pickImageFromGallery();
                        },
                        child: companySetupController.logoImagePath == ''
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
                              Text(
                                "Upload Logo",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              5.ht,
                              Text(
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
                            File(companySetupController.logoImagePath!),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    16.ht,
                    CustomTextField(
                      controller: companySetupController.companyNameController,
                      hintText: 'Company Name*',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Company Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Company Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    5.ht,
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 12.sp),
                        5.wd,
                        Text(
                          "This field needs to be filled before you continue.",
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                        ),
                      ],
                    ),
                    16.ht,
                    CustomText(
                      text: "Business Location",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    10.ht,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 173.w,
                          child: CustomTextField(
                            controller: companySetupController.cityController,
                            hintText: 'City*',
                            borderColor: Colors.transparent,
                            selectedBorderColor: AppColors.buttonClr,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              if (value.trim().length < 2) {
                                return 'City must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 173.w,
                          child: CustomTextField(
                            controller: companySetupController.provinceController,
                            hintText: 'Province*',
                            borderColor: Colors.transparent,
                            selectedBorderColor: AppColors.buttonClr,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                // return value;
                                return 'Province is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Province must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    10.ht,
                    CustomTextField(
                      keyboardType: TextInputType.streetAddress,
                      controller: companySetupController.addressController,
                      hintText: 'Company Address',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      // validator: (value) {
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Company Address is required';
                      //   }
                      //   if (value.trim().length < 5) {
                      //     return 'Address must be at least 5 characters';
                      //   }
                      //   return null;
                      // },
                    ),
                    10.ht,
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      controller: companySetupController.contactController,
                      hintText: 'Contact Number',
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      // validator: (value) {
                      //   if (value == null || value.trim().isEmpty) {
                      //     return 'Contact Number is required';
                      //   }
                      //   // Basic phone number validation (adjust regex as needed)
                      //   // if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value.trim())) {
                      //   //   return 'Enter a valid phone number';
                      //   // }
                      //   return null;
                      // },
                    ),
                    62.ht,
                    CustomButton(
                      text: 'Complete',
                      onPressed: _createCompany,
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


// class CompanySetupScreen extends StatelessWidget {
//   CompanySetupScreen({super.key});
//
//   final CompanySetupController companySetupController =
//       Get.put(CompanySetupController());
//   final _formKey = GlobalKey<FormState>();
//   void _createCompany() {
//     if (_formKey.currentState!.validate()) {
//       companySetupController.saveCompany(
//         CompanyModel(
//           logoPath:  companySetupController.logoImagePath, // store the image file name or path
//           companyName:  companySetupController.companyNameController.text.trim(),
//           city:  companySetupController.cityController.text.trim(),
//           province: companySetupController. provinceController.text.trim(),
//           address:  companySetupController.addressController.text.trim(),
//           contactNumber:  companySetupController.contactController.text.trim(),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgClr,
//       appBar: AppBar(
//         leading: InkWell(
//           onTap: () => Get.back(),
//           child: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         backgroundColor: AppColors.bgClr,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: GetBuilder(
//           init: CompanySetupController(),
//           builder: (_){
//             return SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 18.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   30.ht,
//                   CustomText(
//                     text: "Company Setup",
//                     fontSize: 22,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   10.ht,
//                   CustomText(
//                     text: "Please fill in your details to complete profile.",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white70,
//                   ),
//                   20.ht,
//                   CustomText(
//                     text: "Company Logo",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white70,
//                   ),
//                   10.ht,
//                   DottedBorder(
//                     dashPattern: [10, 5],
//                     radius: Radius.circular(30.r),
//                     color: Color(0xFF343A40),
//                     // options: RectDottedBorderOptions(dashPattern: [10, 5],strokeWidth: 2,padding: EdgeInsets.all(16),
//                     child: InkWell(
//                       onTap: ()async{
//                         final path = await companySetupController.pickImageFromGallery();
//                       },
//                       child:companySetupController.logoImagePath ==''
//                           ? Container(
//                         height: 147.h,
//                         padding: EdgeInsets.symmetric(vertical: 30.h),
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF172349),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//
//                             Image.asset(AppImages.uploadIcon,
//                                 height: 36.h, width: 33.w),
//                             6.ht,
//                             Text(
//                               "Upload Logo",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             5.ht,
//                             Text(
//                               "Max 10 MB in .jpg/.jpeg/.png format",
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         )
//                       )
//                           :Container(
//                           height: 147.h,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF172349),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child:Image.file(File(companySetupController.logoImagePath!),fit: BoxFit.fill,)
//                       ),
//                     ),
//                   ),
//                   16.ht,
//                   CustomTextField(
//                     controller: companySetupController.companyNameController,
//                     hintText: 'Company Name',
//                     borderColor: Colors.transparent,
//                     selectedBorderColor: AppColors.buttonClr,
//                     validator: (value) {
//                       if (value == null || value.isEmpty)
//                         return 'Company Name is required';
//                       return null;
//                     },
//                   ),
//                   5.ht,
//                   Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.red, size: 12.sp),
//                       5.wd,
//                       Text(
//                         "This field needs to be filled before you continue.",
//                         style: TextStyle(color: Colors.red, fontSize: 12.sp),
//                       ),
//                     ],
//                   ),
//
//
//                   16.ht,
//                   CustomText(
//                     text: "Business Location",
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white70,
//                   ),
//                   10.ht,
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         width: 173.w,
//                         child: CustomTextField(
//                           controller: companySetupController.cityController,
//                           hintText: 'City*',
//                           borderColor: Colors.transparent,
//                           selectedBorderColor: AppColors.buttonClr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'City is required';
//                             return null;
//                           },
//                         ),
//                       ),
//                       SizedBox(
//                         width: 173.w,
//                         child: CustomTextField(
//                           controller: companySetupController.provinceController,
//                           hintText: 'Province*',
//                           borderColor: Colors.transparent,
//                           selectedBorderColor: AppColors.buttonClr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'Province is required';
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   10.ht,
//                   CustomTextField(
//                     keyboardTyp: TextInputType.streetAddress,
//                     controller: companySetupController.addressController,
//                     hintText: 'Company Address',
//                     borderColor: Colors.transparent,
//                     selectedBorderColor: AppColors.buttonClr,
//                   ),
//                   10.ht,
//                   CustomTextField(
//                     keyboardTyp: TextInputType.phone,
//                     controller: companySetupController.contactController,
//                     hintText: 'Contact Number',
//                     borderColor: Colors.transparent,
//                     selectedBorderColor: AppColors.buttonClr,
//                   ),
//
//
//                   62.ht,
//                   CustomButton(
//                     text: 'Complete',
//                     onPressed: () {
//                       companySetupController.saveCompany(
//                         CompanyModel(
//                           logoPath:  companySetupController.logoImagePath, // store the image file name or path
//                           companyName:  companySetupController.companyNameController.text.trim(),
//                           city:  companySetupController.cityController.text.trim(),
//                           province: companySetupController. provinceController.text.trim(),
//                           address:  companySetupController.addressController.text.trim(),
//                           contactNumber:  companySetupController.contactController.text.trim(),
//                         ),
//                       );
//                     },
//                     color: AppColors.buttonClr,
//                   ),
//                   20.ht,
//                 ],
//               ),
//             );
//           },
//
//
//
//         ),
//       ),
//     );
//   }
// }
