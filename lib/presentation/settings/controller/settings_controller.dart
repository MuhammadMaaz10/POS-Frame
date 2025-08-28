
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
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
                  openQRScanner(context);
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

  // ------------------ QR Code Scanner ------------------
  void openQRScanner(BuildContext context) {
    Get.to(() => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.bgClr,
          title: CustomText(
            text: "Scan QR Code",
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          leading: InkWell(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back, color: Colors.white, weight: 500),
          ),
        ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              try {
                final data = jsonDecode(barcode.rawValue!);
                if (data is Map<String, dynamic>) {
                  Get.back(); // Close scanner
                  addAPIkeyBottomSheet(context, initialData: data);
                } else {
                  showInvalidQR();
                }
              } catch (e) {
                showInvalidQR();
              }
              break;
            }
          }
        },
      ),
    ));
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

        final box =
        await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

        final config = ConfiguredFDMs(
          clientID: clientIDController.text,
          deviceID: deviceIDController.text,
          apiKey: apiKeyController.text,
        );

        await box.add(config);

        CustomGetSnackBar.show(
          title: 'Success',
          message: 'API key saved successfully!',
          backgroundColor: AppColors.buttonClr,
        );

        // Clear fields
        clientIDController.clear();
        deviceIDController.clear();
        apiKeyController.clear();
      });
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








// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:frame_virtual_fiscilation/constants/app_color.dart';
// import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
// import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
// import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:path/path.dart';
//
// import '../../../local_storage/configured_fdms_model.dart';
// import '../../home_screen/controller/home_screen_controller.dart';
//
//
// class SettingsController extends GetxController {
//   final clientIDController = TextEditingController();
//   final deviceIDController = TextEditingController();
//   final apiKeyController = TextEditingController();
//   final isLoading = false.obs;
//
//
//   String? validateClintID(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Clint ID is required';
//     }
//     // if (value.length < 2) {
//     //   return 'Name must be at least 2 characters';
//     // }
//     return null;
//   }
//
//   String? validateDeviceID(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Device ID is required';
//     }
//     // if (value.length < 2) {
//     //   return 'Name must be at least 2 characters';
//     // }
//     return null;
//   }
//
//   final formKey = GlobalKey<FormState>();
//   String? validateAPIkey(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'API key is required';
//     }
//     return null;
//   }
//
//   Future<void> logout() async {
//     var box = await Hive.openBox('settings');
//     await box.put('isUserLoggedIn', false);
//     await box.put('isFromCompany', false);
//     // final homeController = Get.put(HomeScreenController());
//     // homeController.clearQrUrls();
//
//     CustomGetSnackBar.show(
//       title: "Logout Successful",
//       message: "You have been logged out",
//       backgroundColor: AppColors.buttonClr,
//       snackPosition: SnackPosition.TOP,
//     );
//
//
//
//     // Navigate back to the login screen
//     AppRouter.offAllTo(loginScreen); // Ensure this route exists in your app
//   }
//
//   void addAPIkeyBottomSheet(BuildContext context) {
//
//     showModalBottomSheet(
//
//       context: context,
//       backgroundColor: const Color(0xFF000D3A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true, // Enable full-screen scrollable behavior
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 18.w,
//             right: 18.w,
//             top: 18.h,
//             bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
//           ),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomText(
//                         text: 'Configure FDMS',
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                       GestureDetector(onTap: () => Get.back(),
//                         child: Container(
//                           padding: EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                               color: Color(0xFF172349),
//                               shape: BoxShape.circle
//                           ),
//                           child: Icon(
//                             Icons.close,
//                             size: 18.sp,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   20.ht,
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: CustomTextField(
//                           maxLines: 1,
//                           controller: clientIDController,
//                           hintText: "Client ID",
//                           borderColor: Colors.transparent,
//                           selectedBorderColor: AppColors.buttonClr,
//                           validator: validateClintID,
//
//                         ),
//                       ),
//                       8.wd,
//                       Expanded(
//                         child: CustomTextField(
//                           maxLines: 1,
//                           controller: deviceIDController,
//                           hintText: "Device ID",
//                           borderColor: Colors.transparent,
//                           selectedBorderColor: AppColors.buttonClr,
//                           validator: validateDeviceID,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   10.ht,
//                   CustomTextField(
//                     controller: apiKeyController,
//                     hintText: "API Key",
//                     borderColor: Colors.transparent,
//                     selectedBorderColor: AppColors.buttonClr,
//                     validator: validateAPIkey,
//                   ),
//                   30.ht,
//                   CustomButton(
//                     text: "Save",
//                     onPressed: () => saveAPIkey(),
//                   ),
//                   20.ht
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//   void saveAPIkey() {
//     if (formKey.currentState!.validate()) {
//
//       isLoading.value = true;
//       Future.delayed( Duration(seconds: 1), () async{
//         Get.back();
//         isLoading.value = false;
//         var settingsBox = await Hive.openBox('settings');
//         var username = settingsBox.get('loggedInUser');
//         final box=await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');
//         final config = ConfiguredFDMs(
//           clientID: clientIDController.text,
//           deviceID: deviceIDController.text,
//           apiKey: apiKeyController.text,
//         );
//
//         await box.add(config);
//
//         CustomGetSnackBar.show(
//           title: 'Success',
//           message: 'API key saved successfully!',
//           backgroundColor: AppColors.buttonClr,
//           // colorText: AppColors.white,
//         );
//
//         // Clear fields after saving
//         clientIDController.clear();
//         deviceIDController.clear();
//         apiKeyController.clear();
//       });
//     } else {
//       // Get.snackbar(
//       //   'Error',
//       //   selectedImageBytes.value == null
//       //       ? 'Please select an item image'
//       //       : 'Please fill all fields correctly',
//       //   backgroundColor: Colors.red,
//       //   colorText: AppColors.white,
//       // );
//     }
//   }
//
//   @override
//   void onClose() {
//     clientIDController.clear();
//     deviceIDController.clear();
//     apiKeyController.clear();
//     super.onClose();
//   }
// }