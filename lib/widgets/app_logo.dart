import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:get/get.dart';

SvgAppLogo(){
  return Center(child: SvgPicture.asset(AppImages.appLogoSVG,height: 80.w, width: 112.w,));
}
barLogo(){
  return SvgPicture.asset(AppImages.barLogo,height: 40.w, width: 64.32.w,);
}

SvgSocialIcon({required String iconPat}){
  return SvgPicture.asset(iconPat,height: 22.h);
}

settingsIcon({void Function()? onTap}){
  return GestureDetector(onTap: onTap,child: SvgPicture.asset(AppImages.settingsIcon,height: 40.h, width: 40.w,));
}



Widget syncIcon({void Function()? onTap}) {
  final controller = Get.find<HomeScreenController>(); // Get your controller instance

  return GestureDetector(
    onTap: onTap,
    child: Obx(() {
      return Container(
        padding: EdgeInsets.all(11.w),
        decoration: BoxDecoration(
          color: Color(0xFF172349),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: AnimatedRotation(
          turns: controller.isLoading.value ? 50 : 0, // Continuous rotation
          duration: Duration(seconds: controller.isLoading.value ? 50 : 0),
          child: Image.asset(
            AppImages.sync1,
            height: 18.h,
            width: 18.w,
            color: Colors.white,
          ),
        ),
      );
    }),
  );
}
