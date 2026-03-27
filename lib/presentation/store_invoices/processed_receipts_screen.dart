import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/processed_receipt_detail_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  const ReceiptTile({
    super.key,
    required this.receipt,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryClr,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      text: receipt.invoiceNo,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.white,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  CustomText(
                    text:
                        '${receipt.receiptCurrency} ${receipt.receiptTotal.toStringAsFixed(2)}',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.buttonClr,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              6.ht,
              CustomText(
                text: formatDate(receipt.receiptDate),
                fontSize: 12,
                color: Colors.white70,
                textAlign: TextAlign.start,
              ),
              8.ht,
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
    );
  }
}
