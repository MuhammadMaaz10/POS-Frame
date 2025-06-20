import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_images.dart';

class SmallRoundedButton extends StatelessWidget {
  const SmallRoundedButton({
    super.key,
    required this.size,
    this.imgUrl = AppImages.googleLogo,
    this.text = "Google",
  });

  final Size size;
  final String? imgUrl;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: size.width * .3,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.secondaryClr,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imgUrl!),
              SizedBox(width: 10),
              Text(
                text!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}