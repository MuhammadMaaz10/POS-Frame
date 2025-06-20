import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/controller/settings_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/tax_group/tax_group_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Settings",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: AppColors.white, weight: 500),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.ht,
            Container(
              padding: EdgeInsets.symmetric(horizontal:16.w, vertical: 18.h),
              decoration: BoxDecoration(
                  color: Color(0xFF172349),
                  borderRadius: BorderRadius.circular(10.r)
              ),
              child: Column(
                children: [
                  customTile(
                    title: "Tax Group Management",
                    onTap: () => Get.to(TaxGroupScreen()),
                    iconPath: AppImages.taxIcon
                  ),
                  customTile(
                    title: "Bluetooth Printer Setup",
                      iconPath: AppImages.printerIcon
                  ),
                  customTile(
                    title: "Configure FDMS",
                    onTap: () => controller.addAPIkeyBottomSheet(context),
                      iconPath: AppImages.fdmsIcon
                  ),

                  customTile(
                    title: "Terms & Conditions",
                      iconPath: AppImages.termsCondIcon
                  ),

                  customTile(
                    title: "Support & Help",
                      iconPath: AppImages.helpIcon
                  ),

                  customTile(
                    title: "App & Info",
                      iconPath: AppImages.infoIcon
                  ),

                  customTile(
                    title: "Theme",
                      iconPath: AppImages.themeIcon,
                    showDivider: false
                  ),
                ],
              )
            ),
              270.ht,
            GestureDetector(
              onTap: () => controller.logout(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5.h),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10.r)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppImages.logoutIcon),
                  10.wd,
                  CustomText(
                    text: "Logout",
                    fontWeight: FontWeight.w500,
                    color: AppColors.redClr,
                  ),
                    ],
                )
              ),
            ),

            ],
          ),
        ),
      ),
    );
  }

}
customTile({bool showDivider = true,required String title, String? iconPath, Widget? leading,void Function()? onTap}){
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading == null ? SvgPicture.asset(iconPath.toString(),color: Colors.white70,height: 16.h,):leading,
          10.wd,
          CustomText(
            text: "$title",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          Spacer(),
          GestureDetector(onTap: onTap,child: Icon(Icons.arrow_forward_ios,color: Colors.white70,size: 18,)),
        ],
      ),
      showDivider == true ?
      Padding(
        padding: EdgeInsets.symmetric(vertical: 18.5.h),
        child: Divider(height: 1,color: Color(0xFF343A40),),
      ):SizedBox(),
    ],
  );
}