import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_day_report/model/fiscal_day_report_model.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_day_report/view/report_preview_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FiscalDayReportController extends GetxController {
  final fiscalDayNoController = TextEditingController(text: "1");
  var isLoading = false.obs;
  FiscalDayReportModel? reportModel;

  void incrementDay() {
    int currentVal = int.tryParse(fiscalDayNoController.text) ?? 0;
    fiscalDayNoController.text = (currentVal + 1).toString();
  }

  void decrementDay() {
    int currentVal = int.tryParse(fiscalDayNoController.text) ?? 0;
    if (currentVal > 1) {
      fiscalDayNoController.text = (currentVal - 1).toString();
    }
  }

  Future<void> fetchReport() async {
    if (fiscalDayNoController.text.isEmpty) {
      CustomGetSnackBar.show(
          title: "Error", message: "Please enter a fiscal day number");
      return;
    }

    final int dayNo = int.tryParse(fiscalDayNoController.text) ?? 0;
    final int deviceId = int.tryParse(fiscalDeviceID) ?? 0;

    if (deviceId == 0) {
      CustomGetSnackBar.show(
          title: "Error", message: "Device ID is missing or invalid");
      return;
    }

    isLoading.value = true;
    try {
      final url = Uri.parse(zReportUrl(deviceId, dayNo));
      print("🌐 Z-Report API URL: $url");
      print("🔑 Z-Report API Key being sent: $fiscalApiKey");

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'apiKey': fiscalApiKey,
        },
      );

      print("📡 Z-Report Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        reportModel = FiscalDayReportModel.fromJson(data);
        Get.to(() => ReportPreviewScreen());
      } else {
        print("❌ Z-Report Failed Response: ${response.body}");
        CustomGetSnackBar.show(
            title: "Error", message: "Failed to generate report. ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception during Z-Report fetch: $e");
      CustomGetSnackBar.show(
          title: "Error", message: "An error occurred while fetching the report.");
    } finally {
      isLoading.value = false;
    }
  }
}
