import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_device_management/controller/fiscal_day_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FiscalDeviceManagementScreen extends StatelessWidget {
   FiscalDeviceManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Fiscal Device Management",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: Colors.white, weight: 500),
        ),
        actions: [
          GetBuilder<FiscalDeviceManagementController>(builder: (controller) {
            return Padding(
              padding: EdgeInsets.only(right: 18.w),
              child: syncIcon(
                onTap: () {
                  controller.getFiscalDayData();
                },
              ),
            );
          },)
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: GetBuilder<FiscalDeviceManagementController>(builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SvgAppLogo(), // App logo consistent with branding
                SizedBox(height: 30.h),
                Container(
                  height: 236.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeletonizer(
                          enabled: controller.isLoading,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                  text:
                                  "DAY ${controller.fiscalDayModel?.serverResponse?.lastFiscalDayNo.toString()}",
                                  color: Colors.white70,
                                  fontSize: 14),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(7.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.circle,
                                        size: 10, color: AppColors.white),
                                    SizedBox(width: 4),
                                    CustomText(
                                      text: "${controller.fiscalDayModel?.serverResponse?.fiscalDayStatus.toString()}",
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      50.ht,

                      Center(
                        child: Skeletonizer(
                          enabled: controller.isLoading,
                          containersColor: AppColors.bgClr,
                          child: Text(
                            controller.countdownText.value,
                            // countDownTimerFromAPI,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ),
                      // Obx(() {
                      //   return Center(
                      //     child: Skeletonizer(
                      //       enabled: controller.isLoading,
                      //       containersColor: AppColors.bgClr,
                      //       child: Text(
                      //         controller.countdownText.value,
                      //         // countDownTimerFromAPI,
                      //         style: const TextStyle(
                      //           fontSize: 36,
                      //           fontWeight: FontWeight.bold,
                      //           color: AppColors.green,
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }),
                      const Spacer(),
                      // Progress Bar at the bottom
                      Obx(() {
                        // Total duration in seconds (24 hours = 86400 seconds)
                        final totalSeconds = Duration(hours: 24).inSeconds;
                        final remainingSeconds =
                            controller.countdownDuration.value.inSeconds;
                        final progress = remainingSeconds / totalSeconds; // 1 → 0
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            color: AppColors.green,
                            minHeight: 6,
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                16.ht,
                CustomText(
                    text: "Once day is closed, invoices can’t be created.",
                    color: Colors.white70),
                SizedBox(height: 235.h),
                CustomActionButton(
                  loading: fiscalDayStatus != "FiscalDayOpened"
                      ? controller.isLoading2
                      : controller.isLoading3,
                  text: fiscalDayStatus != "FiscalDayOpened" ?  "Open Day" :"Close Day",
                  color: fiscalDayStatus != "FiscalDayOpened" ?  AppColors.green : AppColors.redClr,
                  icon:fiscalDayStatus != "FiscalDayOpened" ? Icons.play_arrow : Icons.stop,
                  onTap: () {
                    final nextDay = (controller.fiscalDayModel!.serverResponse!.lastFiscalDayNo ?? 0) + 1;



                    fiscalDayStatus != "FiscalDayOpened"
                        ? controller.openDay(day: nextDay.toString())
                        : controller.closeDay(day: controller.fiscalDayModel!.serverResponse!.lastFiscalDayNo.toString());
                    print("${controller.isLoading3}");
                  },
                ),
                SizedBox(height: 20.h),
                SupportText(),
                SizedBox(height: 20.h),
              ],
            );
          },),
        ),
      ),
    );
  }
}

class CustomActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool loading;
  final IconData icon;
  final VoidCallback onTap;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.color,
    this.loading = false,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100.h,
        // width: 174.w, // same as in your Figma
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: loading == true
            ? Center(child: SizedBox(height: 40.h, width: 40.w,child: CircularProgressIndicator(color: AppColors.white,)))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportText extends StatelessWidget {
  const SupportText({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@frame.co.zw',
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Hello, I need help with...',
      },
    );

    if (!await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $emailUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.normal),
        children: [
          const TextSpan(text: "Please contact support at ",style: TextStyle(color: Colors.white70)),
          TextSpan(
            text: "support@frame.co.zw",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _launchEmail,
          ),
          const TextSpan(text: " if you experience any challenges.",style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

