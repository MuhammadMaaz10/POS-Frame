import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';

class CustomSocialButton extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onPressed;

  const CustomSocialButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 37.w,vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFF172349),
          borderRadius: BorderRadius.circular(12.r)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgSocialIcon(iconPat: icon),
            20.wd,
            CustomText(
              text: text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            )
          ],
        ),
      ),
    );
  }
}