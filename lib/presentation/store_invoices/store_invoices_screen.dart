import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/item_detail/store_invoice_item_detail_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/store_invoice_preview_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreInvoicesScreen extends StatelessWidget {
  /// When true, screen is embedded in home (no app bar; parent provides it).
  final bool embedded;

  StoreInvoicesScreen({super.key, this.embedded = false});
  final controller = Get.put(StoreInvoicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: embedded
          ? null
          : AppBar(
              backgroundColor: AppColors.bgClr,
              title: CustomText(
                text: "Store Invoices",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back, color: AppColors.white, weight: 500),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Currency Selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Currency",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  10.ht,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryClr,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Obx(() => DropdownButton<String>(
                      dropdownColor: AppColors.bgClr,
                      isExpanded: true,
                      underline: SizedBox(),
                      value: controller.selectedCurrency.value,
                      items: ['USD', 'ZWG'].map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: CustomText(
                            text: currency,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        );
                      }).toList(),
                      onChanged: controller.updateSelectedCurrency,
                    )),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: CustomTextField(
                controller: controller.searchController,
                hintText: "Search items",
                prefixIcon: Icons.search,
                borderColor: Colors.transparent,
                selectedBorderColor: AppColors.buttonClr,
              ),
            ),

            16.ht,

            // Items Grid
            Expanded(
              child: Obx(() {
                if (controller.errorMessage.value != null &&
                    !controller.isLoadingItems.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            text: controller.errorMessage.value ?? '',
                            color: Colors.white70,
                          ),
                          12.ht,
                          CustomButton(
                            text: 'Retry',
                            onPressed: () => controller.loadItemsFromApi(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.filteredItemList.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: controller.isLoadingItems.value
                          ? "Loading items..."
                          : "No items found",
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive (mobile/tablet) row-based layout: more stable than GridView sizing.
                    final mq = MediaQuery.of(context);
                    final shortestSide = mq.size.shortestSide;
                    final isTablet = shortestSide >= 600;

                    int crossAxisCount;
                    if (isTablet) {
                      crossAxisCount =
                          mq.orientation == Orientation.landscape ? 5 : 4;
                    } else {
                      crossAxisCount = constraints.maxWidth >= 390 ? 3 : 2;
                    }

                    final showSkeleton = controller.isLoadingItems.value;
                    final items = controller.filteredItemList;
                    final skeletonItemCount = crossAxisCount * 4;
                    final rowCount = showSkeleton
                        ? (skeletonItemCount / crossAxisCount).ceil()
                        : (items.length / crossAxisCount).ceil();
                    final rowGap = 10.h;
                    final colGap = 10.w;

                    // Fixed card height keeps text from clipping across devices.
                    final cardHeight = isTablet ? 150.h : 140.h;

                    final listView = ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                      itemCount: rowCount,
                      itemBuilder: (context, rowIndex) {
                        final start = rowIndex * crossAxisCount;
                        // end is not required; we use absoluteIndex bounds checks

                        return Padding(
                          padding: EdgeInsets.only(bottom: rowGap),
                          child: Row(
                            children: List.generate(crossAxisCount, (colIndex) {
                              final isLastCol = colIndex == crossAxisCount - 1;
                              final absoluteIndex = start + colIndex;

                              if (!showSkeleton &&
                                  absoluteIndex >= items.length) {
                                return Expanded(child: SizedBox());
                              }

                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: isLastCol ? 0 : colGap,
                                  ),
                                  child: SizedBox(
                                    height: cardHeight,
                                    child: showSkeleton
                                        ? StoreInvoiceItemCard(
                                            title: 'Loading item',
                                            priceText: '0.00',
                                            quantity: 0,
                                            isSelected: false,
                                            onRemove: () {},
                                            onAdd: () {},
                                            onTap: null,
                                          )
                                        : Obx(() {
                                            final item = items[absoluteIndex];
                                            final isSelected =
                                                controller.isItemSelected(item);
                                            final quantity =
                                                controller.getItemQuantity(item);

                                            return StoreInvoiceItemCard(
                                              title: item.itemName,
                                              priceText: item.price
                                                  .toStringAsFixed(2),
                                              quantity: quantity,
                                              isSelected: isSelected,
                                              onRemove: () =>
                                                  controller.removeItem(item),
                                              onAdd: () =>
                                                  controller.addItem(item),
                                              onTap: () => Get.to(
                                                () => StoreInvoiceItemDetailScreen(
                                                  item: item,
                                                  currency:
                                                      controller.selectedCurrency.value,
                                                ),
                                              ),
                                            );
                                          }),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    );

                    return Skeletonizer(
                      enabled: showSkeleton,
                      child: listView,
                    );
                  },
                );
              }),
            ),

            // Bottom Summary and Preview Button
            Obx(() {
              final hasSelectedItems = controller.selectedQuantities.isNotEmpty;
              return Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.secondaryClr,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasSelectedItems) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "Total Items",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                          CustomText(
                            text: "${controller.getTotalQuantity()}",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                      8.ht,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "Grand Total",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                          CustomText(
                            text: "${controller.selectedCurrency.value} ${controller.calculateGrandTotal().toStringAsFixed(2)}",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.buttonClr,
                          ),
                        ],
                      ),
                      16.ht,
                    ],
                    CustomButton(
                      text: hasSelectedItems ? "Preview Invoice" : "Select Items",
                      onPressed: hasSelectedItems
                          ? () {
                              Get.to(() => StoreInvoicePreviewScreen());
                            }
                          : () {
                              // Show message to select items
                              Get.snackbar(
                                "No Items Selected",
                                "Please select items to create an invoice",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.secondaryClr,
                                colorText: AppColors.white,
                              );
                            },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

}

class StoreInvoiceItemCard extends StatelessWidget {
  final String title;
  final String priceText;
  final int quantity;
  final bool isSelected;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  const StoreInvoiceItemCard({
    super.key,
    required this.title,
    required this.priceText,
    required this.quantity,
    required this.isSelected,
    required this.onRemove,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 10.h),
          decoration: BoxDecoration(
            color: AppColors.secondaryClr,
            borderRadius: BorderRadius.circular(10.r),
            border: isSelected
                ? Border.all(color: AppColors.buttonClr, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36.h,
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      fontFamily: 'Satoshi',
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              6.ht,
              CustomText(
                text: priceText,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.buttonClr,
                textAlign: TextAlign.center,
              ),
              6.ht,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.buttonClr
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: isSelected ? Colors.black : Colors.white70,
                        size: 14.sp,
                      ),
                    ),
                  ),
                  4.wd,
                  SizedBox(
                    width: 30.w,
                    child: CustomText(
                      text: quantity.toString(),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  4.wd,
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 22.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: AppColors.buttonClr,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

