import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_images.dart';
import 'TextField.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({
    super.key,
    this.isLogoEnabled = true,
    this.maintext = "Sign In",
    this.subtext = "Don't have an account? ",
    this.sublinktext = "Sign Up",
    this.subtextColor = const Color(0xFF00E3FC), this.onSublinktextClick,
  });

  final bool isLogoEnabled;
  final String? maintext;
  final String? subtext;
  final Color? subtextColor;
  final String? sublinktext;
  final Function? onSublinktextClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLogoEnabled
            ? Center(child: Image.asset(AppImages.mainLogo,width:  112.w,))
            : SizedBox(),
        isLogoEnabled ? SizedBox(height: 40.h) : SizedBox(),
        Text(
          maintext!,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Flexible(
              child: RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: subtext,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // TextSpan(
                    //   text: sublinktext,
                    //   style: TextStyle(
                    //     color: Colors.white.withOpacity(0.7),
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            sublinktext != null
                ? InkWell(
                  onTap: (){
                    onSublinktextClick!();
                  } ,
                  child: Text(
                    sublinktext!,
                    style: TextStyle(
                      color: Color(0xFF00E3FC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : SizedBox(),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
