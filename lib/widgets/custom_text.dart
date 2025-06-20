import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final String? fontFamily;
  final double fontSize;
  final TextDecoration? decoration;
  final FontWeight fontWeight;
  final Color color;
  final Color? decorationColor;
  final TextAlign textAlign;

  const CustomText({
    Key? key,
    required this.text,
    this.fontFamily,
    this.decorationColor,
    this.decoration,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = AppColors.white,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
            fontFamily: fontFamily??'Satoshi',
            fontSize: fontSize.sp,
            fontWeight: fontWeight,
            color: color,
          decoration: decoration,
          decorationColor: decorationColor,
          ),
    );
  }
}