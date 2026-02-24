
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_device_management/controller/fiscal_day_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/qr_code_scanner/qr_code_scanner_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/splash_screen/splash_screen.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../local_storage/configured_fdms_model.dart';

/// SharedPreferences key for store-invoices mode toggle on home screen.
const String _kUseStoreInvoicesMode = 'useStoreInvoicesMode';
/// ---------------------------------------------------------------------------
/// SETTINGS CONTROLLER
/// ---------------------------------------------------------------------------
/// Handles FDMS configuration, API key storage, QR scanning setup, validation,
/// logout operations, permission requests, and loading saved configurations.
/// Uses Hive for local storage and GetX for state management.
/// ---------------------------------------------------------------------------

class SettingsController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    loadStoreInvoicesMode();
  }

  // ---------------------------------------------------------------------------
  // TEXT CONTROLLERS
  // ---------------------------------------------------------------------------

  /// Input field for Client ID
  final clientIDController = TextEditingController();

  /// Input field for Device ID
  final deviceIDController = TextEditingController();

  /// Input field for API Key
  final apiKeyController = TextEditingController();

  // ---------------------------------------------------------------------------
  // REACTIVE STATE & VALIDATION
  // ---------------------------------------------------------------------------

  /// Loader for UI state (true = loading)
  final isLoading = false.obs;

  /// Form key for validation of manual API entry
  final formKey = GlobalKey<FormState>();

  /// When true, home screen shows Store Invoices flow; when false, default Invoices/Items/Customers.
  final useStoreInvoicesMode = false.obs;

  // ---------------------------------------------------------------------------
  // STORE INVOICES MODE TOGGLE (persisted)
  // ---------------------------------------------------------------------------

  /// Loads persisted store-invoices toggle from SharedPreferences.
  Future<void> loadStoreInvoicesMode() async {
    final prefs = await SharedPreferences.getInstance();
    useStoreInvoicesMode.value = prefs.getBool(_kUseStoreInvoicesMode) ?? false;
  }

  /// Toggles store-invoices mode and persists the value.
  Future<void> setStoreInvoicesMode(bool value) async {
    useStoreInvoicesMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseStoreInvoicesMode, value);
  }

  // ---------------------------------------------------------------------------
  // INPUT VALIDATORS
  // ---------------------------------------------------------------------------

  /// Validates Client ID field
  String? validateClintID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Client ID is required';
    }
    return null;
  }

  /// Validates Device ID field
  String? validateDeviceID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Device ID is required';
    }
    return null;
  }

  /// Validates API key field
  String? validateAPIkey(String? value) {
    if (value == null || value.isEmpty) {
      return 'API key is required';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // FDMS CONFIGURATION CHECK
  // ---------------------------------------------------------------------------

  /// Checks whether FDMS is configured.
  /// If not configured → shows a dialog forcing user to configure first.
  Future<void> checkFDMSConfig(BuildContext context) async {
    print("🔍 checkFDMSConfig() called...");

    final settingsBox = await Hive.openBox('settings');
    final bool isConfigured = settingsBox.get('isFDMSConfigured', defaultValue: false);

    // AppConstant.isAppConfigured = isConfigured;

    print("📦 FDMS Configured status from Hive: $isConfigured");
    print(" AppConstant.isAppConfigured: ${AppConstant.isAppConfigured}");

    if (!isConfigured) {
      print("⚠️ FDMS not configured → showing dialog...");
      Future.delayed(
        const Duration(milliseconds: 300),
            () => _showInitialConfigDialog(context),
      );
    } else {
      print("✅ FDMS already configured → no dialog needed.");
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE API KEY & CONFIGURATION
  // ---------------------------------------------------------------------------

  /// Saves Client ID, Device ID, and API Key to Hive.
  /// Marks FDMS as configured and refreshes app state.
  void saveAPIkey() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      Future.delayed(const Duration(seconds: 1), () async {
        Get.back();
        isLoading.value = false;

        final settingsBox = await Hive.openBox('settings');
        final username = settingsBox.get('loggedInUser');

        final configBox =
        await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

        final config = ConfiguredFDMs(
          clientID: clientIDController.text,
          deviceID: deviceIDController.text,
          apiKey: apiKeyController.text,
        );

        // Save newest configuration
        await configBox.put('apiConfig', config);

        // Mark FDMS as configured
        await settingsBox.put('isFDMSConfigured', true);

        CustomGetSnackBar.show(
          title: 'Success',
          message: 'API key saved successfully!',
          backgroundColor: AppColors.buttonClr,
        );

        loadAndPrintConfigs();

        // Debug print
        await Future.delayed(const Duration(seconds: 3));


        // Restart to Splash → refresh everything
        Get.offAll(() => SplashScreen());

        // Clear fields after saving
        clientIDController.clear();
        deviceIDController.clear();
        apiKeyController.clear();
      });
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD & APPLY SAVED CONFIGURATIONS
  // ---------------------------------------------------------------------------

  /// Loads stored FDMS configurations and initializes the fiscal device.
  Future<void> loadAndPrintConfigs() async {
    print('-----------loadAndPrintConfigs--------------');

    final settingsBox = await Hive.openBox('settings');
    final username = settingsBox.get('loggedInUser');

    final configBox =
    await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

    // print('Total configs in box: ${configBox.length}');

    if (configBox.isEmpty) {
      print('⚠️ No configs found for user: $username');
      return;
    }

    int index = 0;
    for (var config in configBox.values) {
      // print('Config #$index');
      // print('Client ID: ${config.clientID}');
      fiscalDeviceID = config.deviceID;
      fiscalApiKey = config.apiKey;

      print('client ID: $config.clientID');
      print('Device ID: $fiscalDeviceID');
      print('API Key: ${config.apiKey}');
      print('-------------------------');

      update();

      if (fiscalDeviceID.isNotEmpty) {
        // print("----- Valid Device ID Found → Fetching Fiscal Day --------");
        Get.put(FiscalDeviceManagementController()).getFiscalDayData();
      } else {
        // print("----- fiscalDeviceID is EMPTY, skipping fiscal day call --------");
      }

      index++;
    }
  }

  // ---------------------------------------------------------------------------
  // INITIAL CONFIGURATION DIALOG (Blocking)
  // ---------------------------------------------------------------------------

  /// Shows a blocking dialog asking user to configure FDMS before using app.
  void _showInitialConfigDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF000D3A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Configuration Required",
            style: TextStyle(fontFamily: 'Satoshi', color: Colors.white),
          ),
          content: const CustomText(
            text: "Please configure FDMS before using the app.",
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
                color: AppColors.buttonClr,
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  /// Logs out user by resetting login flags and navigating to login screen.
  Future<void> logout() async {
    final box = await Hive.openBox('settings');

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

  // ---------------------------------------------------------------------------
  // CONFIG OPTION SHEET (QR or Manual Entry)
  // ---------------------------------------------------------------------------

  /// Shows bottom sheet to choose between QR scan or manual configuration.
  void showConfigOptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000D3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
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

                // Scan QR
                CustomButton(
                  text: "Scan QR Code",
                  onPressed: () {
                    Get.back();
                    Get.to(QRScannerScreen());
                  },
                ),
                const SizedBox(height: 12),

                // Manual Entry
                CustomButton(
                  text: "Enter Manually",
                  onPressed: () {
                    Get.back();
                    addAPIkeyBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PERMISSIONS
  // ---------------------------------------------------------------------------

  /// Requests camera access for QR scanning.
  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar("Permission Denied", "Camera access is required for scanning.");
    }
  }

  /// Alerts user about invalid QR format.
  void showInvalidQR() {
    Get.snackbar(
      "Error",
      "Invalid QR Code format",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ---------------------------------------------------------------------------
  // MANUAL FDMS ENTRY (BOTTOM SHEET)
  // ---------------------------------------------------------------------------

  /// Opens bottom sheet allowing manual entry of Client ID, Device ID, API Key.
  /// [initialData] is auto-filled when coming from QR scan.
  void addAPIkeyBottomSheet(
      BuildContext context, {
        Map<String, dynamic>? initialData,
      }) {
    // Prefill values from QR
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
                    // Header
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

                    // Client ID + Device ID
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
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

                    // API Key
                    CustomTextField(
                      controller: apiKeyController,
                      hintText: "API Key",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateAPIkey,
                    ),

                    30.ht,

                    // SAVE BUTTON
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

  // ---------------------------------------------------------------------------
  // CONTROLLER CLEANUP
  // ---------------------------------------------------------------------------

  @override
  void onClose() {
    clientIDController.clear();
    deviceIDController.clear();
    apiKeyController.clear();
    super.onClose();
  }
}
