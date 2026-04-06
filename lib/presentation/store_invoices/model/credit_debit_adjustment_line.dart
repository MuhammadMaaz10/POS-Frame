import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';

/// One editable line for credit/debit adjustment (maps to FDMS receipt line).
class CreditDebitAdjustmentLine {
  final String id;
  String receiptLineHSCode;
  String receiptLineType;
  String receiptLineName;
  double receiptLineQuantity;
  double receiptLineTotal;
  double taxPercent;
  int taxID;

  CreditDebitAdjustmentLine({
    required this.id,
    required this.receiptLineHSCode,
    required this.receiptLineType,
    required this.receiptLineName,
    required this.receiptLineQuantity,
    required this.receiptLineTotal,
    required this.taxPercent,
    required this.taxID,
  });

  factory CreditDebitAdjustmentLine.fromReceiptLine(ReceiptLineReceipt r) {
    return CreditDebitAdjustmentLine(
      id: 'line_${r.receiptLineNo}_${r.receiptLineName.hashCode}',
      receiptLineHSCode: r.receiptLineHSCode,
      receiptLineType: r.receiptLineType,
      receiptLineName: r.receiptLineName,
      receiptLineQuantity: r.receiptLineQuantity,
      receiptLineTotal: r.receiptLineTotal,
      taxPercent: r.taxPercent,
      taxID: r.taxID,
    );
  }

  factory CreditDebitAdjustmentLine.empty({
    required String id,
    required double defaultTaxPercent,
    required int defaultTaxId,
  }) {
    return CreditDebitAdjustmentLine(
      id: id,
      receiptLineHSCode: '99001000',
      receiptLineType: 'Sale',
      receiptLineName: '',
      receiptLineQuantity: 1,
      receiptLineTotal: 0,
      taxPercent: defaultTaxPercent,
      taxID: defaultTaxId,
    );
  }

  /// Tax amount for this line when totals are tax-inclusive.
  double taxAmountInclusive() {
    if (receiptLineTotal <= 0 || taxPercent <= 0) return 0;
    return receiptLineTotal * taxPercent / (100 + taxPercent);
  }

  /// Tax amount when lines are tax-exclusive (net line total).
  double taxAmountExclusive() {
    if (receiptLineTotal <= 0 || taxPercent <= 0) return 0;
    return receiptLineTotal * taxPercent / 100;
  }

  double taxAmount(bool receiptLinesTaxInclusive) {
    return receiptLinesTaxInclusive
        ? taxAmountInclusive()
        : taxAmountExclusive();
  }
}
