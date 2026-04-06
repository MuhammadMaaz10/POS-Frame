import 'dart:math' as math;

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Splits [invoiceNo] into a static prefix and trailing digits (suffix).
/// Example: `INV-FR-4-00013` → prefix `INV-FR-4-`, suffix `13`, digitLen `5`.
class InvoiceParts {
  final String prefix;
  final int suffix;
  final int digitLen;

  const InvoiceParts({
    required this.prefix,
    required this.suffix,
    required this.digitLen,
  });
}

InvoiceParts? splitInvoiceNumber(String invoiceNo) {
  final m = RegExp(r'^(.*?)(\d+)$').firstMatch(invoiceNo.trim());
  if (m == null) return null;
  final g2 = m.group(2)!;
  return InvoiceParts(
    prefix: m.group(1)!,
    suffix: int.parse(g2),
    digitLen: g2.length,
  );
}

/// Receipt with the latest [receiptDate] (ISO), or null if none parse.
ProcessedReceipt? latestReceiptByDate(List<ProcessedReceipt> receipts) {
  ProcessedReceipt? best;
  DateTime? bestDt;
  for (final r in receipts) {
    DateTime? dt;
    try {
      dt = DateTime.parse(r.receiptDate);
    } catch (_) {
      continue;
    }
    if (bestDt == null || dt.isAfter(bestDt)) {
      bestDt = dt;
      best = r;
    }
  }
  return best;
}

/// Max numeric suffix among receipts whose [invoiceNo] starts with `INV-STORE-`.
int _maxInvStoreSuffix(List<ProcessedReceipt> receipts) {
  var m = 0;
  for (final r in receipts) {
    final inv = r.invoiceNo;
    if (!inv.toUpperCase().startsWith('INV-STORE-')) continue;
    final p = splitInvoiceNumber(inv);
    if (p != null && p.suffix > m) m = p.suffix;
  }
  return m;
}

int _invStorePadFromList(List<ProcessedReceipt>? receipts) {
  var pad = 4;
  if (receipts == null) return pad;
  for (final r in receipts) {
    if (!r.invoiceNo.toUpperCase().startsWith('INV-STORE-')) continue;
    final p = splitInvoiceNumber(r.invoiceNo);
    if (p != null && p.digitLen > pad) pad = p.digitLen;
  }
  return pad;
}

int _sequenceFromPersistedInvStoreOnly() {
  final last = AppConstant.lastInvoiceNumber.trim();
  if (last.isEmpty) return 0;
  if (!last.toUpperCase().startsWith('INV-STORE-')) return 0;
  return splitInvoiceNumber(last)?.suffix ?? 0;
}

/// Fallback when API list is empty or unparsable: next `INV-STORE-*` only.
String _generateNextInvStoreOnly({List<ProcessedReceipt>? apiReceipts}) {
  final fromList = apiReceipts == null || apiReceipts.isEmpty
      ? 0
      : _maxInvStoreSuffix(apiReceipts);
  final fromPersist = _sequenceFromPersistedInvStoreOnly();
  final base = math.max(fromList, fromPersist);
  final pad = _invStorePadFromList(apiReceipts);
  final next = base + 1;
  final nextStr =
      next.toString().padLeft(math.max(pad, next.toString().length), '0');
  return 'INV-STORE-$nextStr';
}

/// Next **store** fiscal invoice number:
/// - If the GET `/receipts` list has items: use the **same prefix / padding** as the
///   **latest invoice by date**, and increment within that family (same logic as credit/debit).
/// - Otherwise: fallback to `INV-STORE-*` from list + persisted.
String generateNextStoreInvoiceNumber({List<ProcessedReceipt>? apiReceipts}) {
  if (apiReceipts != null && apiReceipts.isNotEmpty) {
    final latest = latestReceiptByDate(apiReceipts);
    if (latest != null && splitInvoiceNumber(latest.invoiceNo) != null) {
      return generateNextInvoiceForCreditDebit(
        original: latest,
        apiReceipts: apiReceipts,
      );
    }
  }
  return _generateNextInvStoreOnly(apiReceipts: apiReceipts);
}

/// Single entry point for the next invoice on **submit**:
/// - [original] is **null** → new **store** fiscal invoice (template from latest API receipt).
/// - [original] set → **credit/debit** note for that receipt’s family.
String generateNextInvoiceForSubmit({
  ProcessedReceipt? original,
  List<ProcessedReceipt>? apiReceipts,
}) {
  if (original != null) {
    return generateNextInvoiceForCreditDebit(
      original: original,
      apiReceipts: apiReceipts,
    );
  }
  return generateNextStoreInvoiceNumber(apiReceipts: apiReceipts);
}

/// Next number in the same **prefix family** as [original], using max suffix in
/// [apiReceipts] for that prefix + matching persisted submit.
String generateNextInvoiceForCreditDebit({
  required ProcessedReceipt original,
  List<ProcessedReceipt>? apiReceipts,
}) {
  final orig = splitInvoiceNumber(original.invoiceNo);
  if (orig == null) {
    return _generateNextInvStoreOnly(apiReceipts: apiReceipts);
  }
  final prefix = orig.prefix;
  var maxS = orig.suffix;
  var padLen = orig.digitLen;

  if (apiReceipts != null) {
    for (final r in apiReceipts) {
      if (!r.invoiceNo.startsWith(prefix)) continue;
      final p = splitInvoiceNumber(r.invoiceNo);
      if (p == null || p.prefix != prefix) continue;
      if (p.suffix > maxS) maxS = p.suffix;
      if (p.digitLen > padLen) padLen = p.digitLen;
    }
  }

  final persisted = AppConstant.lastInvoiceNumber.trim();
  if (persisted.isNotEmpty && persisted.startsWith(prefix)) {
    final pp = splitInvoiceNumber(persisted);
    if (pp != null && pp.prefix == prefix) {
      if (pp.suffix > maxS) maxS = pp.suffix;
      if (pp.digitLen > padLen) padLen = pp.digitLen;
    }
  }

  final next = maxS + 1;
  final nextStr =
      next.toString().padLeft(math.max(padLen, next.toString().length), '0');
  return '$prefix$nextStr';
}

/// Backward-compatible alias: no API list (INV-STORE fallback only).
String generateNextInvoiceNumberFromLast() {
  return _generateNextInvStoreOnly(apiReceipts: null);
}

/// Updates memory and SharedPreferences so the next generated number increments.
Future<void> persistLastInvoiceNumber(String invoiceNo) async {
  AppConstant.lastInvoiceNumber = invoiceNo;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastInvoiceNumber', invoiceNo);
}
