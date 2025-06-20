import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/reset_password_screen/controller/reset_password_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ResetPasswordController resetPassController = Get.put(ResetPasswordController());
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      resetPassController.resetPassword(
        resetPassController.passwordController.text,
        resetPassController.confirmPassController.text,
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
                  text: "Reset Password",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                10.ht,
                CustomText(
                  text: "Create a new password to reset your account.",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                40.ht,
                CustomTextField(
                  controller: resetPassController.passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  hintText: 'New Password',
                  // prefixIcon: Icons.lock,
                  suffixIcon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  maxLines: 1,
                  obscureText: !_isPasswordVisible,
                  onSuffixTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password is required';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                16.ht,
                CustomTextField(
                  controller: resetPassController.confirmPassController,
                  hintText: 'Confirm New Password',
                  keyboardType: TextInputType.visiblePassword,
                  // prefixIcon: Icons.lock,
                  suffixIcon: _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  maxLines: 1,
                  obscureText: !_isConfirmPasswordVisible,
                  onSuffixTap: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm Password is required';
                    if (value != resetPassController.passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                400.ht,
                CustomButton(
                  text: 'Reset',
                  onPressed: _resetPassword,
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