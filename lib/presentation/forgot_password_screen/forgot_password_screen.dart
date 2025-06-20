import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/forgot_password_screen/controller/forget_password_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/TextField.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:frame_virtual_fiscilation/widgets/form_header.dart';
import 'package:frame_virtual_fiscilation/widgets/rounded_button.dart';
import 'package:frame_virtual_fiscilation/widgets/validation.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final ForgetPasswordController forgetPassController = Get.put(ForgetPasswordController());
  final _formKey = GlobalKey<FormState>();
  void _forgotPassword() {
    if (_formKey.currentState!.validate()) {
      forgetPassController.checkEmailAndNavigate(
        forgetPassController.emailController.text.trim(),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.ht,
                CustomText(
                  text: "Forgot Password",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),

                10.ht,
                CustomText(
                  text: "Enter your email address and we’ll send you an OTP to reset your password.",
                  fontSize: 15,
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                40.ht,
                CustomTextField(
                  controller: forgetPassController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Email Address',
                  // prefixIcon: Icons.email,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: validateEmail,
                ),
                466.ht,
                CustomButton(
                  text: 'Continue',
                  onPressed: _forgotPassword,
                  color: AppColors.buttonClr,
                ),
                // 20.ht,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
