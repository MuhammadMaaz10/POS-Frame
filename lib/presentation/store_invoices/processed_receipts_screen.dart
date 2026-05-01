import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/credit_debit_adjustment_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/processed_receipt_detail_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Scrollable list of processed receipts (pull-to-refresh + load more).
/// Use [disposeControllerOnDispose]: `true` when shown alone; `false` when embedded in tabs.
class ProcessedReceiptsListBody extends StatefulWidget {
  final bool disposeControllerOnDispose;

  const ProcessedReceiptsListBody({
    super.key,
    this.disposeControllerOnDispose = false,
  });

  @override
  State<ProcessedReceiptsListBody> createState() =>
      _ProcessedReceiptsListBodyState();
}

class _ProcessedReceiptsListBodyState extends State<ProcessedReceiptsListBody> {
  late final ProcessedReceiptsController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ProcessedReceiptsController>()) {
      Get.put(ProcessedReceiptsController());
    }
    controller = Get.find<ProcessedReceiptsController>();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 280) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    if (widget.disposeControllerOnDispose &&
        Get.isRegistered<ProcessedReceiptsController>()) {
      Get.delete<ProcessedReceiptsController>();
    }
    super.dispose();
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  void _openAdjustment(ProcessedReceipt receipt) {
    Get.to(
      () => CreditDebitAdjustmentScreen(receipt: receipt),
    )?.then((result) async {
      if (result == true) {
        await controller.refreshReceipts();
      }
    });
  }

  void _showVerifySheet(
    BuildContext context,
    ProcessedReceipt receipt,
  ) {
    showVerifyInvoiceBottomSheet(
      context,
      receipt: receipt,
      formatDate: _formatDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.receipts.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!controller.isLoading.value &&
          controller.receipts.isEmpty &&
          controller.errorMessage.value == null) {
        return Center(
          child: CustomText(
            text: 'No processed invoices yet.',
            color: Colors.white70,
          ),
        );
      }

      if (controller.errorMessage.value != null &&
          controller.receipts.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: controller.errorMessage.value ?? '',
                  color: Colors.white70,
                  textAlign: TextAlign.center,
                ),
                16.ht,
                TextButton(
                  onPressed: controller.refreshReceipts,
                  child: CustomText(
                    text: 'Retry',
                    color: AppColors.buttonClr,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.buttonClr,
        onRefresh: controller.refreshReceipts,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: controller.receipts.length +
              (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.receipts.length) {
              return Padding(
                padding: EdgeInsets.all(16.h),
                child: Center(
                  child: controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                ),
              );
            }

            final r = controller.receipts[index];
            return ReceiptTile(
              receipt: r,
              formatDate: _formatDate,
              onTap: () => Get.to(
                () => ProcessedReceiptDetailScreen(receipt: r),
              ),
              onAdjust: () => _openAdjustment(r),
              onLongPress: () => _showVerifySheet(context, r),
            );
          },
        ),
      );
    });
  }
}

/// Full-screen route with app bar (optional direct navigation).
class ProcessedReceiptsScreen extends StatelessWidget {
  const ProcessedReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: 'Processed invoices',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: const ProcessedReceiptsListBody(disposeControllerOnDispose: true),
    );
  }
}

class ReceiptTile extends StatelessWidget {
  final ProcessedReceipt receipt;
  final String Function(String) formatDate;
  final VoidCallback onTap;
  final VoidCallback onAdjust;
  final VoidCallback? onLongPress;

  const ReceiptTile({
    super.key,
    required this.receipt,
    required this.formatDate,
    required this.onTap,
    required this.onAdjust,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryClr,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: onTap,
                    child: Text(
                      receipt.invoiceNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: CustomText(
                      text:
                          '${receipt.receiptCurrency} ${receipt.receiptTotal.toStringAsFixed(2)}',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.buttonClr,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
            6.ht,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: formatDate(receipt.receiptDate),
                          fontSize: 12,
                          color: Colors.white70,
                          textAlign: TextAlign.start,
                        ),
                        6.ht,
                        CustomText(
                          text: receipt.buyerData.buyerRegisterName,
                          fontSize: 13,
                          color: AppColors.white,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
                6.wd,
                _ReceiptCreditDebitButton(onPressed: onAdjust),
              ],
            ),
          ],
        ),
      ),
    );
    if (onLongPress == null) return card;
    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

/// Long-press on a receipt → verify actions (QR not available yet).
void showVerifyInvoiceBottomSheet(
  BuildContext context, {
  required ProcessedReceipt receipt,
  required String Function(String) formatDate,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _VerifyInvoiceSheet(
      receipt: receipt,
      formatDate: formatDate,
    ),
  );
}

class _VerifyInvoiceSheet extends StatelessWidget {
  final ProcessedReceipt receipt;
  final String Function(String) formatDate;

  const _VerifyInvoiceSheet({
    required this.receipt,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgClr,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 12.h + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Verify Invoice?',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: AppColors.white, size: 24.sp),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
              14.ht,
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryClr,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: receipt.buyerData.buyerRegisterName,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                          8.ht,
                          CustomText(
                            text: receipt.invoiceNo,
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          4.ht,
                          CustomText(
                            text: formatDate(receipt.receiptDate),
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          8.ht,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              CustomText(
                                text: 'Document Type: ',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              Text(
                                receipt.receiptType.isEmpty
                                    ? '—'
                                    : receipt.receiptType,
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.buttonClr,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(
                          text:
                              '${receipt.receiptCurrency} ${receipt.receiptTotal.toStringAsFixed(2)}',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              16.ht,
              _verifySheetButton(
                label: 'Invoice preview',
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => ProcessedReceiptDetailScreen(receipt: receipt));
                },
              ),
              8.ht,
              _verifySheetButton(
                label: 'Verify',
                onPressed: () async {

                  if (receipt.qrUrl != null && receipt.qrUrl!.isNotEmpty) {
                    await launchQR(receipt.qrUrl!);
                  } else {
                    Get.snackbar(
                      'Verify',
                      'No QR URL is available right now',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.secondaryClr,
                      colorText: AppColors.white,
                    );
                  }

                  print("invoice url ---> ${receipt.qrUrl}");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 launchQR(String qrUrl) async {
  try {
    if (qrUrl.isEmpty) {
      throw Exception("Empty URL");
    }

    final uri = Uri.tryParse(qrUrl);

    if (uri == null) {
      throw Exception("Invalid URL");
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception("Cannot launch URL");
    }
  } catch (e) {
    CustomGetSnackBar.show(
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      title: 'Error',
      message: 'Could not open QR URL',
      backgroundColor: Colors.red,
    );
  }
}

Widget _verifySheetButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    height: 42.h,
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonClr,
        foregroundColor: Colors.black87,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

/// Compact pill for credit/debit; separate from card tap target.
class _ReceiptCreditDebitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ReceiptCreditDebitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.buttonClr, width: 1.2),
            color: AppColors.buttonClr.withValues(alpha: 0.14),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 15.sp,
                  color: AppColors.buttonClr,
                ),
                4.wd,
                CustomText(
                  text: 'Credit / Debit',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.buttonClr,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
