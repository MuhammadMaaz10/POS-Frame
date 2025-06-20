import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool obscureText;
  final bool? enabled;
  final int? maxLines;
  final void Function()? onTap;
  final VoidCallback? onSuffixTap;
  final Color borderColor;
  final Color selectedBorderColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onSuffixTap,
    required this.borderColor,
    required this.selectedBorderColor,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      style:  TextStyle(color: AppColors.white,fontSize: 14.sp, fontWeight: FontWeight.w500),
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w500,color: Colors.white70),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon, color: Colors.white70,size: 18.sp,),
          onPressed: onSuffixTap,)
            : null,
        filled: true,
        fillColor: const Color(0xFF172349),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: selectedBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}