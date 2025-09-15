
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_device_management/controller/fiscal_day_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/qr_code_scanner/qr_code_scanner_screen.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../local_storage/configured_fdms_model.dart';

class SettingsController extends GetxController {
  /// Text Controllers
  final clientIDController = TextEditingController();
  final deviceIDController = TextEditingController();
  final apiKeyController = TextEditingController();

  /// Reactive loading indicator
  final isLoading = false.obs;

  /// Form validation keys
  final formKey = GlobalKey<FormState>();

  // ------------------ Validators ------------------
  String? validateClintID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Client ID is required';
    }
    return null;
  }

  String? validateDeviceID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Device ID is required';
    }
    return null;
  }

  String? validateAPIkey(String? value) {
    if (value == null || value.isEmpty) {
      return 'API key is required';
    }
    return null;
  }

  /// ✅ Check if FDMS is configured, if not, show dialog
  Future<void> checkFDMSConfig(BuildContext context) async {
    print("🔍 checkFDMSConfig() called...");

    var settingsBox = await Hive.openBox('settings');
    bool isConfigured = settingsBox.get('isFDMSConfigured', defaultValue: false);

    print("📦 FDMS Configured status from Hive: $isConfigured");

    if (!isConfigured) {
      print("⚠️ FDMS not configured → showing dialog...");
      Future.delayed(const Duration(milliseconds: 300), () {
        _showInitialConfigDialog(context);
      });
    } else {
      print("✅ FDMS already configured → no dialog needed.");
    }
  }


  void _showInitialConfigDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF000D3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Configuration Required",
            style: TextStyle(fontFamily: 'Satoshi',color: Colors.white),
          ),
          content: const CustomText(
            text:
            "Please configure FDMS before using the app.",
            color: Colors.white70,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showConfigOptionSheet(context);
              },
              child: const CustomText(
                  text: "OK",
                  fontSize: 16,
                  color: AppColors.buttonClr
              ),
            ),
          ],
        );
      },
    );
  }



  // ------------------ Logout ------------------
  Future<void> logout() async {
    var box = await Hive.openBox('settings');
    await box.put('isUserLoggedIn', false);
    await box.put('isFromCompany', false);

    CustomGetSnackBar.show(
      title: "Logout Successful",
      message: "You have been logged out",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );

    AppRouter.offAllTo(loginScreen);
  }

  // ------------------ show Options in Dialog ------------------
  void showConfigOptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000D3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(18),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Configure FDMS',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF172349),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Scan QR Button
                CustomButton(
                  text: "Scan QR Code",
                  onPressed: () {
                    Get.back();
                    Get.to(QRScannerScreen());

                    // openQRScanner(context);
                  },
                ),
                const SizedBox(height: 12),

                // Manual Entry Button
                CustomButton(
                  text: "Enter Manually",
                  onPressed: () {
                    Get.back();
                    addAPIkeyBottomSheet(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar("Permission Denied", "Camera access is required for scanning.");
    }
  }
  void showInvalidQR() {
    Get.snackbar(
      "Error",
      "Invalid QR Code format",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ------------------ Bottom Sheet ------------------
  void addAPIkeyBottomSheet(BuildContext context,
      {Map<String, dynamic>? initialData}) {
    // Prefill data if coming from QR
    if (initialData != null) {
      clientIDController.text = initialData["clientId"] ?? '';
      deviceIDController.text = initialData["deviceId"] ?? '';
      apiKeyController.text = initialData["apiKey"] ?? '';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000D3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: 'Configure FDMS',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF172349),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.ht,
                    // Input fields row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            maxLines: 1,
                            controller: clientIDController,
                            hintText: "Client ID",
                            borderColor: Colors.transparent,
                            selectedBorderColor: AppColors.buttonClr,
                            validator: validateClintID,
                          ),
                        ),
                        8.wd,
                        Expanded(
                          child: CustomTextField(
                            maxLines: 1,
                            controller: deviceIDController,
                            hintText: "Device ID",
                            borderColor: Colors.transparent,
                            selectedBorderColor: AppColors.buttonClr,
                            validator: validateDeviceID,
                          ),
                        ),
                      ],
                    ),
                    10.ht,
                    // API key input
                    CustomTextField(
                      controller: apiKeyController,
                      hintText: "API Key",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateAPIkey,
                    ),
                    30.ht,
                    // Save button
                    CustomButton(
                      text: "Save",
                      onPressed: () => saveAPIkey(),
                    ),
                    20.ht,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------ Save API Key ------------------
  void saveAPIkey() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () async {
        Get.back();
        isLoading.value = false;

        var settingsBox = await Hive.openBox('settings');
        var username = settingsBox.get('loggedInUser');

        final box = await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

        final config = ConfiguredFDMs(
          clientID: clientIDController.text,
          deviceID: deviceIDController.text,
          apiKey: apiKeyController.text,
        );

        // ✅ Save in a single key (overwrite every time)
        await box.put('apiConfig', config);

        // ✅ Mark FDMS as configured (no need new function)
        await settingsBox.put('isFDMSConfigured', true);

        CustomGetSnackBar.show(
          title: 'Success',
          message: 'API key saved successfully!',
          backgroundColor: AppColors.buttonClr,
        );

        await Future.delayed(const Duration(seconds: 5));
        loadAndPrintConfigs();

        // Clear fields
        clientIDController.clear();
        deviceIDController.clear();
        apiKeyController.clear();
      });
    }
  }

  Future<void> loadAndPrintConfigs() async {
    print('-----------loadAndPrintConfigs--------------');
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');

    final box = await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

    print('Total configs in box: ${box.length}');
    // Clean if there are old entries from before


    if (box.isEmpty) {
      print('⚠️ No configs found for user: $username');
      return;
    }

    int index = 0;
    for (var config in box.values) {
      print('Config #$index');
      print('Client ID: ${config.clientID}');
      fiscalDeviceID = config.deviceID;
      fiscalApiKey = config.apiKey;
      print('Device ID: ${fiscalDeviceID}');
      update();
      if(fiscalDeviceID != ""){
        print("--------------- fiscalDeviceID is ${fiscalDeviceID} --------");
        Get.put(FiscalDeviceManagementController()).getFiscalDayData();
      }else{
        print("--------------- fiscalDeviceID is empty --------");
      }
      print('API Key: ${config.apiKey}');
      print('-------------------------');
      index++;
    }
  }







  @override
  void onClose() {
    clientIDController.clear();
    deviceIDController.clear();
    apiKeyController.clear();
    super.onClose();
  }
}
