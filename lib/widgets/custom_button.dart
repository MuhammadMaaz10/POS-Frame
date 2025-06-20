import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Assuming you're using flutter_screenutil

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
        HapticFeedback.lightImpact(); // Haptic feedback on tap
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.buttonClr, // Button background color
        padding: EdgeInsets.symmetric(vertical: 17.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        minimumSize: Size(double.infinity, 0), // Full width
        elevation: 2, // Slight elevation for Material Design effect
        disabledBackgroundColor: (color ?? AppColors.buttonClr).withOpacity(0.5), // Dim when disabled
      ),
      child: isLoading
          ? SizedBox(
        height: 20.h,
        width: 20.w,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      )
          : CustomText(
        text: text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF333333),
      ),
    );
  }
}

class CustomSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;

  const CustomSmallButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
        HapticFeedback.lightImpact(); // Haptic feedback on tap
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.buttonClr, // Button background color
        padding: EdgeInsets.symmetric(vertical: 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        minimumSize: Size(double.infinity, 0), // Full width
        elevation: 2, // Slight elevation for Material Design effect
        disabledBackgroundColor: (color ?? AppColors.buttonClr).withOpacity(0.5), // Dim when disabled
      ),
      child: isLoading
          ? SizedBox(
        height: 20.h,
        width: 20.w,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.black,
              ),
              4.wd,
              CustomText(
                      text: text,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
            ],
          ),
    );
  }
}


// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;
//   final Color? color;
//
//   const CustomButton({
//     Key? key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.color,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: isLoading ? null : onPressed,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 17.h),
//         decoration: BoxDecoration(
//             color: AppColors.buttonClr,
//             borderRadius: BorderRadius.circular(12.r)
//         ),
//         child: isLoading
//             ? SizedBox(height: 20.h,width: 10.w ,child: Center(child: const CircularProgressIndicator(color: Colors.black)))
//             : CustomText(
//           text: text,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF333333),
//         ),
//       ),
//     );
//   }
// }