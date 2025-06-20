import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';

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