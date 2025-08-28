import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatelessWidget {
  final Function(Map<String, dynamic> data) onScanned;

  const QRScannerScreen({Key? key, required this.onScanned}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        backgroundColor: Colors.blueAccent,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(barcode.rawValue!);
                Navigator.pop(context); // Close scanner
                onScanned(data); // Pass data back
              } catch (e) {
                Get.snackbar("Error", "Invalid QR Code format",
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
              break;
            }
          }
        },
      ),
    );
  }
}
