import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

// GetX Controller for Fiscal Device Management
// Inside your FiscalDeviceManagementController
class FiscalDeviceManagementController extends GetxController {
  var isDayOpen = false.obs;
  var isServerOnline = true.obs;
  var dayNumber = 1.obs;
  var countdownDuration = Duration(hours: 24).obs;
  var countdownText = "24:00:00".obs;
  Timer? _timer;

  final int totalSeconds = 24 * 60 * 60; // 24 hours in seconds
  var progress = 1.0.obs; // for progress bar (1.0 = full)

  @override
  void onInit() {
    super.onInit();
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    countdownDuration.value = Duration(seconds: totalSeconds);
    progress.value = 1.0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownDuration.value.inSeconds > 0) {
        countdownDuration.value -= const Duration(seconds: 1);

        // update text
        countdownText.value = _formatDuration(countdownDuration.value);

        // update progress
        progress.value = countdownDuration.value.inSeconds / totalSeconds;
      } else {
        timer.cancel();
        countdownText.value = "00:00:00";
        progress.value = 0.0;
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void openDay() {
    isDayOpen.value = true;
    dayNumber.value += 1;
    _startCountdownTimer();
    Get.snackbar(
        "Success", "Fiscal Day ${dayNumber.value} opened successfully");
  }

  void closeDay() {
    isDayOpen.value = false;
    _timer?.cancel();
    countdownText.value = "00:00:00";
    progress.value = 0.0;
    Get.snackbar(
        "Success", "Fiscal Day ${dayNumber.value} closed successfully");
  }
}

// Fiscal Device Management Screen
class FiscalDeviceManagementScreen extends StatelessWidget {
  const FiscalDeviceManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FiscalDeviceManagementController());

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
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: syncIcon(
              onTap: () {
                // controller.processReceiptsSequentially();
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                            text: "DAY 23",
                            color: Colors.white70,
                            fontSize: 14),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle,
                                  size: 10, color: AppColors.white),
                              SizedBox(width: 4),
                              CustomText(
                                text: "Online",
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    50.ht,
                    Obx(() {
                      return Center(
                        child: Text(
                          controller.countdownText.value,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      );
                    }),
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
              SizedBox(height: 278.h),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomActionButton(
                    text: "Stop",
                    color: AppColors.redClr,
                    icon: Icons.stop,
                    onTap: () {
                      print("Stop tapped");
                    },
                  ),
                  8.wd,
                  CustomActionButton(
                    text: "Start",
                    color: AppColors.green,
                    icon: Icons.play_arrow,
                    onTap: () {
                      print("Start tapped");
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const CustomActionButton({
    super.key,
    required this.text,
    required this.color,
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
        width: 174.w, // same as in your Figma
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
