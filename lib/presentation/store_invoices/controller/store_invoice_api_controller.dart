import 'dart:convert';

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// ANSI codes for colored console output (supported in most terminals/IDEs).
const _blue = '\x1B[34m';
const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _reset = '\x1B[0m';

/// Separate provider for store invoicing API.
/// Builds FDMS receipt payload from store invoice fields and submits to the receipts API.
class StoreInvoiceApiController extends GetxController {
  final _storeController = Get.find<StoreInvoicesController>();

  final isSubmitting = false.obs;
  final submitError = RxnString();
  final lastSubmitSuccess = false.obs;

  /// Builds the FDMS receipt payload from current store invoice data (fields we already have).
  Map<String, dynamic> buildReceiptPayload() {
    final currency = _storeController.selectedCurrency.value;
    final grandTotal = _storeController.calculateGrandTotal();
    final totalTax = _storeController.calculateTotalTax();
    final byId = {for (final it in _storeController.itemList) it.id: it};

    final receiptLines = <Map<String, dynamic>>[];
    int lineNo = 1;
    for (final entry in _storeController.selectedQuantities.entries) {
      final item = byId[entry.key];
      if (item == null) continue;
      final quantity = entry.value;
      final lineTotal = _storeController.calculateItemTotal(
        item,
        quantity: quantity,
      );
      receiptLines.add({
        'receiptLineHSCode': '99001000',
        'receiptLineType': 'Sale',
        'receiptLineNo': lineNo++,
        'receiptLineName': item.itemName,
        'receiptLineQuantity': quantity,
        'receiptLineTotal': lineTotal.toStringAsFixed(2),
        'taxPercent': item.taxGroup.toInt(),
        'taxID': 2,
      });
    }

    final receiptTotalStr = grandTotal.toStringAsFixed(2);
    final receiptTaxStr = totalTax.toStringAsFixed(2);

    return {
      'receiptType': 'FiscalInvoice',
      'receiptCurrency': currency,
      'receiptGlobalNo': int.tryParse(AppConstant.fiscalDayNumber) ?? 1,
      'invoiceNo': _generateInvoiceNo(),
      'buyerData': {
        'buyerRegisterName': 'Walk-in Customer',
        'buyerTIN': '0000000000',
        'buyerVAT': '',
        'buyerAddress': {
          'houseNumber': '',
          'street': '',
          'city': '',
          'province': '',
        },
      },
      'receiptLinesTaxInclusive': true,
      'receiptLines': receiptLines,
      'receiptPayments': [
        {
          'moneyTypeCode': 'CASH',
          'paymentAmount': receiptTotalStr,
        },
      ],
      'receiptTotal': receiptTotalStr,
      'receiptTaxAmount': receiptTaxStr,
      'receiptPrintForm': 'Receipt48',
    };
  }

  String _generateInvoiceNo() {
    final last = AppConstant.lastInvoiceNumber;
    if (last.isEmpty) return 'INV-STORE-0001';
    final numPart = int.tryParse(last.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numPart == null) return 'INV-STORE-0001';
    return 'INV-STORE-${(numPart + 1).toString().padLeft(4, '0')}';
  }

  /// Submits the store invoice (fields data) to the receipts API.
  /// Call this from the preview screen when user confirms.
  Future<bool> submitStoreInvoice() async {
    if (fiscalDeviceID.isEmpty) {
      submitError.value = 'Fiscal device not configured';
      return false;
    }
    if (_storeController.selectedQuantities.isEmpty) {
      submitError.value = 'No items selected';
      return false;
    }

    isSubmitting.value = true;
    submitError.value = null;
    lastSubmitSuccess.value = false;

    try {
      final url = Uri.parse(createReceiptUrl);
      final apiKey = fiscalApiKey.isNotEmpty
          ? fiscalApiKey
          : 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7';
      final payload = buildReceiptPayload();
      final bodyJson = jsonEncode(payload);

      // Console: request (blue)
      print('$_blue[StoreInvoice API] POST $url$_reset');
      print('$_blue[StoreInvoice API] Request body:\n${const JsonEncoder.withIndent('  ').convert(payload)}$_reset');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'apiKey': apiKey,
        },
        body: bodyJson,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Console: success (green)
        print('$_green[StoreInvoice API] Response status: ${response.statusCode}$_reset');
        print('$_green[StoreInvoice API] Response body: ${response.body}$_reset');
        lastSubmitSuccess.value = true;
        submitError.value = null;
        return true;
      } else {
        // Console: error (red)
        print('$_red[StoreInvoice API] Response status: ${response.statusCode}$_reset');
        print('$_red[StoreInvoice API] Response body: ${response.body}$_reset');
        submitError.value =
            'Failed to create receipt (${response.statusCode}): ${response.body}';
        return false;
      }
    } catch (e) {
      // Console: exception (red)
      print('$_red[StoreInvoice API] Error: $e$_reset');
      submitError.value = 'Error: $e';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearSubmitState() {
    submitError.value = null;
    lastSubmitSuccess.value = false;
  }
}
