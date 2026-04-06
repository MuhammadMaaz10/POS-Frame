import 'dart:convert';

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/credit_debit_adjustment_line.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/utils/invoice_number_generator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Submits a **CreditNote** or **DebitNote** with user-edited lines, referencing
/// a processed receipt from GET `/receipts` (same POST endpoint as fiscal invoices).
Future<bool> submitCreditDebitFromProcessedReceipt({
  required ProcessedReceipt original,
  required String receiptType,
  required List<CreditDebitAdjustmentLine> lines,
  String notes = '',
}) async {
  if (fiscalDeviceID.isEmpty) return false;
  if (receiptType != 'CreditNote' && receiptType != 'DebitNote') return false;
  if (lines.isEmpty) return false;

  final apiKey = fiscalApiKey.isNotEmpty
      ? fiscalApiKey
      : 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7';

  final taxInclusive = original.receiptLinesTaxInclusive;
  double receiptTotal = 0;
  double receiptTax = 0;
  final receiptLines = <Map<String, dynamic>>[];
  int lineNo = 1;
  for (final line in lines) {
    receiptTotal += line.receiptLineTotal;
    receiptTax += line.taxAmount(taxInclusive);
    receiptLines.add({
      'receiptLineHSCode': line.receiptLineHSCode,
      'receiptLineType': line.receiptLineType,
      'receiptLineNo': lineNo++,
      'receiptLineName': line.receiptLineName.trim(),
      'receiptLineQuantity': line.receiptLineQuantity,
      'receiptLineTotal': line.receiptLineTotal.toStringAsFixed(2),
      'taxPercent': line.taxPercent,
      'taxID': line.taxID,
    });
  }

  final totalStr = receiptTotal.toStringAsFixed(2);
  final taxStr = receiptTax.toStringAsFixed(2);

  final deviceId = int.tryParse(fiscalDeviceID) ?? 0;
  final fiscalDay = int.tryParse(AppConstant.fiscalDayNumber) ?? 0;

  final invoiceNo = generateNextInvoiceForSubmit(
    original: original,
    apiReceipts: Get.isRegistered<ProcessedReceiptsController>()
        ? Get.find<ProcessedReceiptsController>().receipts.toList()
        : null,
  );

  final payload = <String, dynamic>{
    'receiptType': receiptType,
    'receiptCurrency': original.receiptCurrency,
    'receiptGlobalNo': int.tryParse(AppConstant.fiscalDayNumber) ?? 1,
    'invoiceNo': invoiceNo,
    'buyerData': {
      'buyerRegisterName': original.buyerData.buyerRegisterName,
      'buyerTIN': original.buyerData.buyerTIN,
      'buyerVAT': original.buyerData.vatNumber ?? '',
      'buyerAddress': {
        'houseNumber': '',
        'street': '',
        'city': '',
        'province': '',
      },
    },
    'receiptLinesTaxInclusive': taxInclusive,
    'receiptLines': receiptLines,
    'receiptPayments': [
      {
        'moneyTypeCode': 'CASH',
        'paymentAmount': totalStr,
      },
    ],
    'receiptTotal': totalStr,
    'receiptTaxAmount': taxStr,
    'receiptPrintForm':
        original.receiptPrintForm.isNotEmpty ? original.receiptPrintForm : 'Receipt48',
    'creditDebitNote': {
      'deviceID': deviceId,
      'receiptGlobalNo': original.receiptGlobalNo ?? 0,
      'fiscalDayNo': fiscalDay,
      'originalInvoice': original.invoiceNo,
    },
  };

  if (notes.isNotEmpty) {
    payload['receiptNotes'] = notes;
  }

  final url = Uri.parse(createReceiptUrl);
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'apiKey': apiKey,
    },
    body: jsonEncode(payload),
  );

  final ok = response.statusCode >= 200 && response.statusCode < 300;
  if (ok) {
    await persistLastInvoiceNumber(invoiceNo);
  }
  return ok;
}
