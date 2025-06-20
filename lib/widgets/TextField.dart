import 'package:flutter/material.dart';

import '../constants/app_color.dart';

class TextInputField extends StatelessWidget {
  TextInputField({
    super.key,
    this.bgColor = AppColors.secondaryClr,
    this.color = AppColors.inputClr,
    this.icon = Icons.email_outlined,
    this.hintText = "example@gmail.com",
    this.label = "Email",
    this.suffixicon,
    this.controller,
    this.minLines = 1,
  });

  int? minLines;
  String? label;
  String? hintText;
  IconData? icon;
  IconData? suffixicon;
  Color? color;
  Color? bgColor;
  TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 52 * (minLines!.toDouble()),
      child: TextFormField(
        controller: controller,
        minLines: minLines,


        maxLines: 5,

        style: TextStyle(
          color: color,
          fontFamily: "Satoshi",
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(
            color: color,
            fontFamily: "Satoshi",
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIconColor: color,
          suffixIconColor: color,
          filled: true,

          fillColor: bgColor,
          prefixIcon: icon != null ? Icon(icon, size: 16) : null,
          suffixIcon: Icon(suffixicon, size: 16),
          labelText: label,
          hintText: hintText,
        ),
      ),
    );
  }
}
