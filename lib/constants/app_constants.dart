import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

String deviceID = '';
String singleInvoiceQrURL = '';
 var fiscalDayStatus = "";
 var fiscalDayNumber = "";
 var fiscalDeviceID = "";
 var fiscalApiKey = "";
 var lastInvoiceNumber = "";
 var countDownTimerFromAPI = "";


Future<void> saveLastInvoiceNumberOnce(String lastInvoiceNumber) async {
  final prefs = await SharedPreferences.getInstance();

  // check if already saved
  final alreadySaved = prefs.getBool('isInvoiceNumberSaved') ?? false;

  if (!alreadySaved) {
    await prefs.setString('lastInvoiceNumber', lastInvoiceNumber);
    await prefs.setBool('isInvoiceNumberSaved', true); // mark as saved
    print("✅ Saved lastInvoiceNumber ONCE: $lastInvoiceNumber");
  } else {
    print("⚠️ Skipping save, already saved once.");
  }
}

extension EmptySpace on num {
  SizedBox get ht => SizedBox(height: toDouble().h);

  SizedBox get wd => SizedBox(width: toDouble().w);
}


class CustomGetSnackBar {
  static void show({
    required String title,
    required String message,
    Color backgroundColor = Colors.white70, // Default button color
    Color textColor = Colors.black,
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      snackPosition: snackPosition,
      duration: duration,
      colorText: textColor,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      // mainButton: TextButton(
      //   onPressed: () {
      //     Get.back(); // Dismiss SnackBar
      //   },
      //   child: const Text('Dismiss'),
      // ),
    );
  }
}

