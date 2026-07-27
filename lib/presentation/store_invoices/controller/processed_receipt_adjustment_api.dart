import 'dart:convert';

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/credit_debit_adjustment_line.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/utils/invoice_number_generator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CreditDebitSubmitResult {
  final bool ok;
  final String? errorMessage;

  const CreditDebitSubmitResult({required this.ok, this.errorMessage});

  factory CreditDebitSubmitResult.success() => const CreditDebitSubmitResult(ok: true);

  factory CreditDebitSubmitResult.failure(String message) =>
      CreditDebitSubmitResult(ok: false, errorMessage: message);
}

/// Submits a **CreditNote** or **DebitNote** with user-edited lines, referencing
/// a processed receipt from GET `/receipts` (same POST endpoint as fiscal invoices).
Future<CreditDebitSubmitResult> submitCreditDebitFromProcessedReceipt({
  required ProcessedReceipt original,
  required String receiptType,
  required List<CreditDebitAdjustmentLine> lines,
  String notes = '',
}) async {
  if (fiscalDeviceID.isEmpty) {
    return CreditDebitSubmitResult.failure('Fiscal device ID is not configured');
  }
  if (receiptType != 'CreditNote' && receiptType != 'DebitNote') {
    return CreditDebitSubmitResult.failure('Invalid receipt type');
  }
  if (lines.isEmpty) {
    return CreditDebitSubmitResult.failure('Add at least one line');
  }

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
    return CreditDebitSubmitResult.success();
  }

  final body = response.body.trim();
  print('[CreditDebit API] POST failed ${response.statusCode}: $body');
  if (body.isEmpty) {
    return CreditDebitSubmitResult.failure(
      'Request failed (${response.statusCode})',
    );
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final message = decoded['message'] ??
          decoded['error'] ??
          decoded['detail'] ??
          decoded['title'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return CreditDebitSubmitResult.failure(message.toString());
      }
    }
  } catch (_) {
    // Fall back to raw body below.
  }
  return CreditDebitSubmitResult.failure(
    body.length > 180 ? '${body.substring(0, 180)}…' : body,
  );
}
