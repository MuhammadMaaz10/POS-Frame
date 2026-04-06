import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipt_adjustment_api.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/credit_debit_adjustment_line.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/inventory_item.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/utils/invoice_number_generator.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

/// Catalog row for the Select Items sheet (original lines + inventory).
class _LineTemplate {
  final String name;
  final String subtitle;
  final double unitPrice;
  final double taxPercent;
  final int taxID;
  final String hsCode;
  final String lineType;

  const _LineTemplate({
    required this.name,
    required this.subtitle,
    required this.unitPrice,
    required this.taxPercent,
    required this.taxID,
    required this.hsCode,
    required this.lineType,
  });

  factory _LineTemplate.fromReceiptLine(ReceiptLineReceipt r) {
    final unit = r.receiptLineQuantity > 0
        ? r.receiptLineTotal / r.receiptLineQuantity
        : r.receiptLineTotal;
    final parts = <String>[];
    if (r.receiptLineType.isNotEmpty) parts.add(r.receiptLineType);
    if (r.receiptLineHSCode.isNotEmpty) parts.add(r.receiptLineHSCode);
    return _LineTemplate(
      name: r.receiptLineName,
      subtitle: parts.isEmpty ? 'Item' : parts.join(' • '),
      unitPrice: unit,
      taxPercent: r.taxPercent,
      taxID: r.taxID,
      hsCode: r.receiptLineHSCode.isNotEmpty ? r.receiptLineHSCode : '99001000',
      lineType: r.receiptLineType.isNotEmpty ? r.receiptLineType : 'Sale',
    );
  }

  factory _LineTemplate.fromInventory(InventoryItem i) {
    final sub = i.description.trim().isNotEmpty ? i.description : i.itemCode;
    return _LineTemplate(
      name: i.itemName,
      subtitle: sub.isNotEmpty ? sub : 'Inventory',
      unitPrice: i.price,
      taxPercent: i.taxGroup,
      taxID: 2,
      hsCode: '99001000',
      lineType: 'Sale',
    );
  }
}

/// Structured credit/debit adjustment: card-style lines, auto total = unit × qty,
/// Select Items bottom sheet. Document type from total vs original.
class CreditDebitAdjustmentScreen extends StatefulWidget {
  final ProcessedReceipt receipt;

  const CreditDebitAdjustmentScreen({
    super.key,
    required this.receipt,
  });

  @override
  State<CreditDebitAdjustmentScreen> createState() =>
      _CreditDebitAdjustmentScreenState();
}

class _CreditDebitAdjustmentScreenState extends State<CreditDebitAdjustmentScreen> {
  final _notesController = TextEditingController();
  late List<_LineRow> _rows;
  var _submitting = false;
  var _pickSerial = 0;

  ProcessedReceipt get _r => widget.receipt;

  @override
  void initState() {
    super.initState();
    _rows = _r.receiptLines
        .map((e) => _LineRow.fromReceiptLine(CreditDebitAdjustmentLine.fromReceiptLine(e)))
        .toList();
    if (_rows.isEmpty) {
      _rows = [
        _LineRow.empty(
          defaultTaxPercent: 0,
          defaultTaxId: 2,
        ),
      ];
    }
    for (final row in _rows) {
      row.nameController.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _attachRowListeners(_LineRow row) {
    row.nameController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  double _originalTotal() => _r.receiptTotal;

  double _newTotal() {
    var s = 0.0;
    for (final row in _rows) {
      s += row.lineTotal;
    }
    return s;
  }

  double _newTax() {
    final taxInclusive = _r.receiptLinesTaxInclusive;
    var s = 0.0;
    for (final row in _rows) {
      final line = row.toLine();
      if (line.receiptLineName.trim().isEmpty) continue;
      if (line.receiptLineTotal <= 0) continue;
      s += line.taxAmount(taxInclusive);
    }
    return s;
  }

  String? _resolveReceiptType() {
    final diff = _newTotal() - _originalTotal();
    if (diff.abs() < 0.001) return null;
    return diff < 0 ? 'CreditNote' : 'DebitNote';
  }

  String _documentTypeLabel() {
    final diff = _newTotal() - _originalTotal();
    if (diff.abs() < 0.001) return '—';
    return diff < 0 ? 'Credit note' : 'Debit note';
  }

  String _documentTypeSubtitle() {
    final diff = _newTotal() - _originalTotal();
    if (diff.abs() < 0.001) {
      return 'Change quantities or add items so the total differs from the original.';
    }
    return diff < 0
        ? 'New total is lower than the original.'
        : 'New total is higher than the original.';
  }

  List<_LineTemplate> _allPickTemplates() {
    final list = <_LineTemplate>[];
    for (final r in _r.receiptLines) {
      list.add(_LineTemplate.fromReceiptLine(r));
    }
    if (Get.isRegistered<StoreInvoicesController>()) {
      final items = Get.find<StoreInvoicesController>().itemList;
      for (final i in items) {
        list.add(_LineTemplate.fromInventory(i));
      }
    }
    return list;
  }

  void _openSelectItemsSheet() {
    final templates = _allPickTemplates();
    final qtys = List<int>.filled(templates.length, 0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModal) {
          return _SelectItemsSheet(
            currency: _r.receiptCurrency,
            templates: templates,
            quantities: qtys,
            onQuantityChanged: () => setModal(() {}),
            onClose: () => Get.back(),
            onAddBlank: () {
              Get.back();
              final first = _rows.first.line;
              setState(() {
                final row = _LineRow.empty(
                  defaultTaxPercent: first.taxPercent,
                  defaultTaxId: first.taxID,
                );
                _attachRowListeners(row);
                _rows.add(row);
              });
            },
            onConfirm: () {
              final toAdd = <({ _LineTemplate t, int q })>[];
              for (var i = 0; i < templates.length; i++) {
                if (qtys[i] > 0) {
                  toAdd.add((t: templates[i], q: qtys[i]));
                }
              }
              if (toAdd.isEmpty && templates.isNotEmpty) {
                Get.snackbar(
                  'Selection',
                  'Set quantity on at least one item.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.redClr,
                  colorText: AppColors.white,
                );
                return;
              }
              if (toAdd.isEmpty && templates.isEmpty) {
                Get.back();
                return;
              }
              Get.back();
              setState(() {
                for (final p in toAdd) {
                  final row = _LineRow.fromTemplate(
                    p.t,
                    p.q,
                    _pickSerial++,
                  );
                  _attachRowListeners(row);
                  _rows.add(row);
                }
              });
            },
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showChangeLineSheet(int index) {
    final row = _rows[index];
    final nameC = TextEditingController(text: row.nameController.text);
    final priceC = TextEditingController(
      text: row.unitPrice > 0 ? row.unitPrice.toStringAsFixed(2) : '',
    );

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.bgClr,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Edit item',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                12.ht,
                CustomText(text: 'Name', fontSize: 12, color: Colors.white54),
                6.ht,
                TextField(
                  controller: nameC,
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondaryClr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                14.ht,
                CustomText(text: 'Unit price (${_r.receiptCurrency})', fontSize: 12, color: Colors.white54),
                6.ht,
                TextField(
                  controller: priceC,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.secondaryClr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                16.ht,
                TextButton(
                  onPressed: () {
                    if (_rows.length <= 1) {
                      Get.snackbar(
                        'Lines',
                        'Keep at least one line.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.redClr,
                        colorText: AppColors.white,
                      );
                      return;
                    }
                    Get.back();
                    setState(() {
                      final r = _rows.removeAt(index);
                      r.dispose();
                    });
                  },
                  child: CustomText(text: 'Remove line', color: AppColors.redClr, fontSize: 14),
                ),
                8.ht,
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      final p = double.tryParse(
                            priceC.text.trim().replaceAll(',', '.'),
                          ) ??
                          0;
                      if (p < 0) return;
                      Get.back();
                      setState(() {
                        row.nameController.text = nameC.text;
                        row.unitPrice = p;
                        row.subtitle = row.line.receiptLineType.isNotEmpty &&
                                row.line.receiptLineHSCode.isNotEmpty
                            ? '${row.line.receiptLineType} • ${row.line.receiptLineHSCode}'
                            : 'Item';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonClr,
                      foregroundColor: AppColors.bgClr,
                    ),
                    child: CustomText(
                      text: 'Save',
                      fontWeight: FontWeight.w700,
                      color: AppColors.bgClr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  List<CreditDebitAdjustmentLine>? _buildLinesForSubmit() {
    final out = <CreditDebitAdjustmentLine>[];
    for (final row in _rows) {
      final line = row.toLine();
      final name = line.receiptLineName.trim();
      if (name.isEmpty) continue;
      if (line.receiptLineTotal <= 0) {
        Get.snackbar(
          'Validation',
          'Line "$name" needs a unit price and quantity.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.redClr,
          colorText: AppColors.white,
        );
        return null;
      }
      out.add(line);
    }
    if (out.isEmpty) {
      Get.snackbar(
        'Validation',
        'Add at least one item with a name, unit price, and quantity.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redClr,
        colorText: AppColors.white,
      );
      return null;
    }
    return out;
  }

  Future<void> _submit() async {
    final lines = _buildLinesForSubmit();
    if (lines == null) return;

    final type = _resolveReceiptType();
    if (type == null) {
      Get.snackbar(
        'Document type',
        'New total matches the original. Change quantities or prices to submit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redClr,
        colorText: AppColors.white,
      );
      return;
    }

    setState(() => _submitting = true);
    final ok = await submitCreditDebitFromProcessedReceipt(
      original: _r,
      receiptType: type,
      lines: lines,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Get.back(result: true);
      Get.snackbar(
        'Success',
        '${type == 'CreditNote' ? 'Credit note' : 'Debit note'} submitted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.bgClr,
        colorText: AppColors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Could not submit. Check device ID and API.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redClr,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diff = _newTotal() - _originalTotal();

    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: 'Adjust invoice',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              text: 'Original ${_r.invoiceNo}',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.start,
            ),
            4.ht,
            CustomText(
              text:
                  '${_r.receiptCurrency} ${_originalTotal().toStringAsFixed(2)} · ${_r.buyerData.buyerRegisterName}',
              fontSize: 13,
              color: Colors.white70,
              textAlign: TextAlign.start,
            ),
            16.ht,
            CustomText(
              text: 'Next invoice no. (on submit)',
              fontSize: 12,
              color: Colors.white54,
              textAlign: TextAlign.start,
            ),
            4.ht,
            Get.isRegistered<ProcessedReceiptsController>()
                ? Obx(() {
                    final list =
                        Get.find<ProcessedReceiptsController>().receipts.toList();
                    return CustomText(
                      text: generateNextInvoiceForSubmit(
                        original: _r,
                        apiReceipts: list,
                      ),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonClr,
                      textAlign: TextAlign.start,
                    );
                  })
                : CustomText(
                    text: generateNextInvoiceForSubmit(
                      original: _r,
                      apiReceipts: null,
                    ),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonClr,
                    textAlign: TextAlign.start,
                  ),
            16.ht,
            CustomText(
              text: 'Document type',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.start,
            ),
            8.ht,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryClr,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: _documentTypeLabel(),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.buttonClr,
                    textAlign: TextAlign.start,
                  ),
                  6.ht,
                  CustomText(
                    text: _documentTypeSubtitle(),
                    fontSize: 12,
                    color: Colors.white60,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            20.ht,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: 'Items',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                TextButton.icon(
                  onPressed: _openSelectItemsSheet,
                  icon: Icon(Icons.add, size: 18.sp, color: AppColors.buttonClr),
                  label: CustomText(
                    text: 'Select items',
                    fontSize: 13,
                    color: AppColors.buttonClr,
                  ),
                ),
              ],
            ),
            8.ht,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rows.length,
              separatorBuilder: (_, __) => 12.ht,
              itemBuilder: (context, index) {
                final row = _rows[index];
                return _AdjustmentItemCard(
                  row: row,
                  currency: _r.receiptCurrency,
                  onChange: () => _showChangeLineSheet(index),
                  onDecQty: () => setState(() => row.decrementQty()),
                  onIncQty: () => setState(() => row.incrementQty()),
                );
              },
            ),
            20.ht,
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.secondaryClr,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _totRow('New subtotal (lines)', _newTotal(), _r.receiptCurrency),
                  6.ht,
                  _totRow('Est. tax', _newTax(), _r.receiptCurrency),
                  12.ht,
                  Divider(color: Colors.white24, height: 1.h),
                  10.ht,
                  _totRow('Original total', _originalTotal(), _r.receiptCurrency),
                  6.ht,
                  _totRow('Difference', diff, _r.receiptCurrency, highlight: true),
                ],
              ),
            ),
            16.ht,
            CustomText(
              text: 'Additional notes (optional)',
              fontSize: 13,
              color: Colors.white70,
              textAlign: TextAlign.start,
            ),
            8.ht,
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Reason or reference',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: AppColors.secondaryClr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            24.ht,
            SizedBox(
              height: 48.h,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonClr,
                  foregroundColor: AppColors.bgClr,
                  disabledBackgroundColor: AppColors.buttonClr,
                  disabledForegroundColor: AppColors.bgClr,
                ),
                child: _submitting
                    ? SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.bgClr,
                        ),
                      )
                    : CustomText(
                        text: 'Submit adjustment',
                        fontWeight: FontWeight.w700,
                        color: AppColors.bgClr,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totRow(String label, double value, String currency, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: label,
          fontSize: 13,
          color: Colors.white70,
        ),
        CustomText(
          text: '$currency ${value.toStringAsFixed(2)}',
          fontSize: highlight ? 15 : 13,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          color: highlight ? AppColors.buttonClr : AppColors.white,
        ),
      ],
    );
  }
}

class _LineRow {
  final CreditDebitAdjustmentLine line;
  late final TextEditingController nameController;
  String subtitle;
  double unitPrice;
  int quantity;

  _LineRow._({
    required this.line,
    required this.subtitle,
    required this.unitPrice,
    required this.quantity,
  }) {
    nameController = TextEditingController(text: line.receiptLineName);
  }

  factory _LineRow.fromReceiptLine(CreditDebitAdjustmentLine l) {
    final qty = _initialQty(l.receiptLineQuantity);
    final up = l.receiptLineQuantity > 0
        ? l.receiptLineTotal / l.receiptLineQuantity
        : (l.receiptLineTotal > 0 ? l.receiptLineTotal : 0.0);
    final parts = <String>[];
    if (l.receiptLineType.isNotEmpty) parts.add(l.receiptLineType);
    if (l.receiptLineHSCode.isNotEmpty) parts.add(l.receiptLineHSCode);
    final sub = parts.isEmpty ? 'Item' : parts.join(' • ');
    return _LineRow._(
      line: l,
      subtitle: sub,
      unitPrice: up,
      quantity: qty,
    );
  }

  factory _LineRow.empty({
    required double defaultTaxPercent,
    required int defaultTaxId,
  }) {
    final l = CreditDebitAdjustmentLine.empty(
      id: 'e_new',
      defaultTaxPercent: defaultTaxPercent,
      defaultTaxId: defaultTaxId,
    );
    return _LineRow._(
      line: l,
      subtitle: 'Item',
      unitPrice: 0,
      quantity: 1,
    );
  }

  factory _LineRow.fromTemplate(_LineTemplate t, int qty, int serial) {
    final l = CreditDebitAdjustmentLine(
      id: 'pick_${serial}_${DateTime.now().microsecondsSinceEpoch}',
      receiptLineHSCode: t.hsCode,
      receiptLineType: t.lineType,
      receiptLineName: t.name,
      receiptLineQuantity: qty.toDouble(),
      receiptLineTotal: t.unitPrice * qty,
      taxPercent: t.taxPercent,
      taxID: t.taxID,
    );
    return _LineRow._(
      line: l,
      subtitle: t.subtitle,
      unitPrice: t.unitPrice,
      quantity: qty,
    );
  }

  static int _initialQty(double q) {
    final n = q.round();
    return n < 1 ? 1 : n;
  }

  double get lineTotal => unitPrice * quantity;

  void incrementQty() {
    quantity += 1;
  }

  void decrementQty() {
    if (quantity > 1) quantity -= 1;
  }

  CreditDebitAdjustmentLine toLine() {
    line.receiptLineName = nameController.text;
    line.receiptLineQuantity = quantity.toDouble();
    line.receiptLineTotal = lineTotal;
    return line;
  }

  void dispose() {
    nameController.dispose();
  }
}

class _AdjustmentItemCard extends StatelessWidget {
  final _LineRow row;
  final String currency;
  final VoidCallback onChange;
  final VoidCallback onDecQty;
  final VoidCallback onIncQty;

  const _AdjustmentItemCard({
    required this.row,
    required this.currency,
    required this.onChange,
    required this.onDecQty,
    required this.onIncQty,
  });

  @override
  Widget build(BuildContext context) {
    final name = row.nameController.text.trim().isEmpty
        ? 'Untitled item'
        : row.nameController.text.trim();
    final total = row.lineTotal;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryClr,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.buttonClr, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Item',
                fontSize: 12,
                color: Colors.white54,
                textAlign: TextAlign.start,
              ),
              TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: CustomText(
                  text: 'Change',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonClr,
                ),
              ),
            ],
          ),
          8.ht,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: name,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      textAlign: TextAlign.start,
                    ),
                    6.ht,
                    CustomText(
                      text: '${row.subtitle} • Qty: ${row.quantity}',
                      fontSize: 12,
                      color: Colors.white54,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              CustomText(
                text: '$currency ${total.toStringAsFixed(2)}',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                textAlign: TextAlign.end,
              ),
            ],
          ),
          14.ht,
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyCircleButton(
                  icon: Icons.remove,
                  enabled: row.quantity > 1,
                  onTap: onDecQty,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomText(
                    text: '${row.quantity}',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                _QtyCircleButton(
                  icon: Icons.add,
                  enabled: true,
                  onTap: onIncQty,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyCircleButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyCircleButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.buttonClr : Colors.white24;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, size: 18.sp, color: color),
        ),
      ),
    );
  }
}

class _SelectItemsSheet extends StatelessWidget {
  final String currency;
  final List<_LineTemplate> templates;
  final List<int> quantities;
  final VoidCallback onQuantityChanged;
  final VoidCallback onClose;
  final VoidCallback onAddBlank;
  final VoidCallback onConfirm;

  const _SelectItemsSheet({
    required this.currency,
    required this.templates,
    required this.quantities,
    required this.onQuantityChanged,
    required this.onClose,
    required this.onAddBlank,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppColors.bgClr,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: 'Select items',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddBlank,
                  icon: Icon(Icons.add, size: 18.sp, color: AppColors.buttonClr),
                  label: CustomText(
                    text: 'Add New',
                    fontSize: 13,
                    color: AppColors.buttonClr,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Flexible(
            child: templates.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: CustomText(
                        text:
                            'No lines on this invoice and no inventory. Tap Add New for a blank line, or open the Store Items tab to load inventory.',
                        fontSize: 13,
                        color: Colors.white54,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: templates.length,
              itemBuilder: (context, i) {
                final t = templates[i];
                final q = quantities[i];
                final selected = q > 0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _SelectItemTile(
                    currency: currency,
                    template: t,
                    quantity: q,
                    selected: selected,
                    onDec: () {
                      if (quantities[i] > 0) {
                        quantities[i]--;
                        onQuantityChanged();
                      }
                    },
                    onInc: () {
                      quantities[i]++;
                      onQuantityChanged();
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonClr,
                    foregroundColor: AppColors.bgClr,
                  ),
                  child: CustomText(
                    text: 'Confirm selection',
                    fontWeight: FontWeight.w700,
                    color: AppColors.bgClr,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectItemTile extends StatelessWidget {
  final String currency;
  final _LineTemplate template;
  final int quantity;
  final bool selected;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _SelectItemTile({
    required this.currency,
    required this.template,
    required this.quantity,
    required this.selected,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryClr,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: selected ? AppColors.buttonClr : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: template.name,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      textAlign: TextAlign.start,
                    ),
                    4.ht,
                    CustomText(
                      text: template.subtitle,
                      fontSize: 12,
                      color: Colors.white54,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: selected ? AppColors.buttonClr : Colors.transparent,
                  border: Border.all(color: AppColors.buttonClr, width: 1.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: selected
                    ? Icon(Icons.check, size: 16.sp, color: AppColors.bgClr)
                    : null,
              ),
            ],
          ),
          10.ht,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: '$currency ${template.unitPrice.toStringAsFixed(2)} ea.',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyCircleButton(
                    icon: Icons.remove,
                    enabled: quantity > 0,
                    onTap: onDec,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: CustomText(
                      text: '$quantity',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  _QtyCircleButton(
                    icon: Icons.add,
                    enabled: true,
                    onTap: onInc,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
