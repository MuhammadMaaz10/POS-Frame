import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';

class PrinterScreen extends StatefulWidget {
  @override
  _PrinterScreenState createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  ReceiptController? _receiptController;
  BluetoothDevice? _selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      // appBar: AppBar(title: Text('Scan & Print Invo  ice')),
      body: SafeArea(
        // top: false,
        // bottom: true,
        child: Column(
          children: [
            Expanded(
              child: Receipt(
                builder: (ctx) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INVOICE',
                        style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text('Item A — \$10'),
                    Text('Item B — \$15'),
                    Divider(),
                    Text('TOTAL — \$25', style: TextStyle(fontSize: 18)),
                  ],
                ),
                onInitialized: (controller) {
                  _receiptController = controller;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                print('[DEBUG] Starting device scan...');
                final address = await FlutterBluetoothPrinter.selectDevice(context);

                if (address != null) {
                  print('[DEBUG] Device selected: $address');
                  if (_receiptController != null) {
                    print('[DEBUG] Printing invoice to $address...');
                    await _receiptController?.print(
                      address: address.toString(),
                      keepConnected: true,
                      addFeeds: 4,
                    );
                    print('[DEBUG] Print job sent successfully.');
                  } else {
                    print('[ERROR] ReceiptController is not initialized.');
                  }
                } else {
                  print('[DEBUG] No device selected.');
                }
              },
              child: Text('Scan for Printers'),
            ),
          ],
        ),
      ),
    );
  }
}
