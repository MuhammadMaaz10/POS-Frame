import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../constants/app_color.dart';
import '../../widgets/app_bar_back_button.dart';
import '../../widgets/custom_text.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false; // flag to prevent duplicate scans

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: const CustomText(
          text: "Scan QR Code",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        leading: const AppBarBackButton(color: Colors.white),
      ),
      body: GetBuilder<SettingsController>(
        builder: (controller) {
          return MobileScanner(
            onDetect: (capture) {
              if (_isProcessing) return; // stop duplicate processing
              _isProcessing = true;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  try {
                    final data = jsonDecode(barcode.rawValue!);
                    if (data is Map<String, dynamic>) {
                      Get.back(); // Close scanner
                      controller.addAPIkeyBottomSheet(context, initialData: data);
                    } else {
                      controller.showInvalidQR();
                      _resetProcessingFlag();
                    }
                  } catch (e) {
                    controller.showInvalidQR();
                    _resetProcessingFlag();
                  }
                  break;
                }
              }
            },
          );
        },
      ),
    );
  }

  void _resetProcessingFlag() {
    Future.delayed(const Duration(seconds: 1), () {
      _isProcessing = false;
    });
  }
}

