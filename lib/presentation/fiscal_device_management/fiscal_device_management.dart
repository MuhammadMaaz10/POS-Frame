import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

// GetX Controller for Fiscal Device Management
class FiscalDeviceManagementController extends GetxController {
  var isDayOpen = false.obs; // Tracks if fiscal day is open or closed
  var isServerOnline = true.obs; // Tracks server status
  var dayNumber = 1.obs; // Fiscal day number
  var countdownDuration = Duration(hours: 24).obs; // 24-hour countdown
  var countdownText = "24:00:00".obs; // Display for countdown
  Timer? _timer;

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

  // Starts the 24-hour countdown timer
  void _startCountdownTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdownDuration.value.inSeconds > 0) {
        countdownDuration.value -= Duration(seconds: 1);
        countdownText.value = _formatDuration(countdownDuration.value);
      } else {
        timer.cancel();
        countdownText.value = "00:00:00";
      }
    });
  }

  // Formats the duration into HH:MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // Handles Open Day action
  void openDay() {
    isDayOpen.value = true;
    dayNumber.value += 1;
    countdownDuration.value = Duration(hours: 24); // Reset countdown
    countdownText.value = _formatDuration(countdownDuration.value);
    _startCountdownTimer();
    Get.snackbar("Success", "Fiscal Day ${dayNumber.value} opened successfully");
  }

  // Handles Close Day action
  void closeDay() {
    isDayOpen.value = false;
    _timer?.cancel();
    countdownText.value = "00:00:00";
    Get.snackbar("Success", "Fiscal Day ${dayNumber.value} closed successfully");
  }

  // Toggles server status (for demo purposes)
  void toggleServerStatus() {
    isServerOnline.value = !isServerOnline.value;
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgAppLogo(), // App logo consistent with branding
            SizedBox(height: 40.h),
            CustomText(
              text: "Fiscal Device Management",
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            // Fiscal Day Status
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: GetBuilder<FiscalDeviceManagementController>(
                builder: (controller) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "Fiscal Day Status",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      text: "Day Number: ${controller.dayNumber.value}",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 5.h),
                    CustomText(
                      text: "Status: ${controller.isDayOpen.value ? 'Open' : 'Closed'}",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: controller.isDayOpen.value ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Server Status
            GestureDetector(
              onTap: controller.toggleServerStatus, // Toggle server status for demo
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Obx(
                      () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: "Server Status",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      CustomText(
                        text: controller.isServerOnline.value ? "Online" : "Offline",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: controller.isServerOnline.value ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Countdown Timer
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Obx(
                    () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: "Countdown Timer",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10.h),
                    CustomText(
                      text: controller.countdownText.value,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.buttonClr,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            // Open/Close Day Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    text: "Open Day",
                    onPressed: controller.openDay,
                    // width: 150.w,
                    // isDisabled: controller.isDayOpen.value,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    text: "Close Day",
                    onPressed: controller.closeDay,
                    // width: 150.w,
                    // isDisabled: !controller.isDayOpen.value,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}