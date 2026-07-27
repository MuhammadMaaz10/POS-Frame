import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/processed_receipts_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoice_api_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/controller/store_invoices_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/item_detail/store_invoice_item_detail_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/processed_receipts_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/store_invoice_preview_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Matches [HomeScreenMain] tab styling (cyan active + thick underline).
Widget _storeInvoicesTabBar(TabController tabController) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.w),
    child: TabBar(
      controller: tabController,
      labelColor: AppColors.buttonClr,
      unselectedLabelColor: AppColors.smallTextClr,
      indicatorColor: AppColors.buttonClr,
      labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.buttonClr, width: 2.w),
        insets: EdgeInsets.symmetric(horizontal: 4.w),
      ),
      dividerColor: Colors.transparent,
      indicatorPadding:
          EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: const [
        Tab(text: 'Items'),
        Tab(text: 'Invoices History'),
      ],
    ),
  );
}

class StoreInvoicesScreen extends StatefulWidget {
  /// When true, screen is embedded in home (no app bar; parent provides it).
  final bool embedded;

  const StoreInvoicesScreen({super.key, this.embedded = false});

  @override
  State<StoreInvoicesScreen> createState() => _StoreInvoicesScreenState();
}

class _StoreInvoicesScreenState extends State<StoreInvoicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final controller = Get.put(StoreInvoicesController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index != 1) return;
    if (!Get.isRegistered<ProcessedReceiptsController>()) {
      Get.put(ProcessedReceiptsController(), permanent: true);
      return;
    }
    Get.find<ProcessedReceiptsController>().refreshReceipts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StoreInvoiceApiController>()) {
      Get.put(StoreInvoiceApiController());
    }
    if (!Get.isRegistered<ProcessedReceiptsController>()) {
      Get.put(ProcessedReceiptsController(), permanent: true);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: AppColors.bgClr,
              title: const CustomText(
                text: "Store Invoices",
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              leading: const AppBarBackButton(color: AppColors.white),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: _storeInvoicesTabBar(_tabController),
              ),
            ),
      // When embedded in Home, parent [SafeArea] already applies insets; a second
      // SafeArea here re-applies top padding and leaves a gap above the tab bar.
      body: SafeArea(
        top: !widget.embedded,
        left: !widget.embedded,
        right: !widget.embedded,
        child: Column(
          children: [
            if (widget.embedded)
              Container(
                width: double.infinity,
                color: AppColors.bgClr,
                child: _storeInvoicesTabBar(_tabController),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  StoreInvoicesDefaultTab(controller: controller),
                  const ProcessedReceiptsListBody(
                    disposeControllerOnDispose: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 1: original store invoice UI (items, preview).
class StoreInvoicesDefaultTab extends StatelessWidget {
  final StoreInvoicesController controller;

  const StoreInvoicesDefaultTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Shared height so search field and currency dropdown align.
    final inputFieldHeight = 48.h;

    return Column(
      children: [
        // Search (left) + compact currency (right)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(
                      text: "Search items",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    8.ht,
                    CustomTextField(
                      controller: controller.searchController,
                      hintText: "Type to filter",
                      prefixIcon: Icons.search,
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      fixedHeight: inputFieldHeight,
                    ),
                  ],
                ),
              ),
              12.wd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(
                    text: "Currency",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  8.ht,
                  SizedBox(
                    width: 100.w,
                    height: inputFieldHeight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryClr,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      alignment: Alignment.center,
                      child: Obx(() => DropdownButton<String>(
                            dropdownColor: AppColors.bgClr,
                            isExpanded: true,
                            isDense: true,
                            underline: const SizedBox(),
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
                  ),
                ],
              ),
            ],
          ),
        ),

        16.ht,

        // Items list (vertical)
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

            final showSkeleton = controller.isLoadingItems.value;
            final items = controller.filteredItemList;
            const skeletonCount = 8;
            final itemCount =
                showSkeleton ? skeletonCount : items.length;

            final listView = ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              itemCount: itemCount,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                if (showSkeleton) {
                  return StoreInvoiceItemCard(
                    title: 'Loading item',
                    priceText: '0.00',
                    quantity: 0,
                    isSelected: false,
                    onRemove: () {},
                    onAdd: () {},
                    onTap: null,
                  );
                }
                return Obx(() {
                  final item = items[index];
                  final isSelected = controller.isItemSelected(item);
                  final quantity = controller.getItemQuantity(item);

                  return StoreInvoiceItemCard(
                    title: item.itemName,
                    priceText: item.price.toStringAsFixed(2),
                    quantity: quantity,
                    isSelected: isSelected,
                    onRemove: () => controller.removeItem(item),
                    onAdd: () => controller.addItem(item),
                    onTap: () => Get.to(
                      () => StoreInvoiceItemDetailScreen(
                        item: item,
                        currency: controller.selectedCurrency.value,
                      ),
                    ),
                  );
                });
              },
            );

            return Skeletonizer(
              enabled: showSkeleton,
              child: listView,
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
                      const CustomText(
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
                      const CustomText(
                        text: "Grand Total",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      CustomText(
                        text:
                            "${controller.selectedCurrency.value} ${controller.calculateGrandTotal().toStringAsFixed(2)}",
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
                          Get.to(() => const StoreInvoicePreviewScreen());
                        }
                      : () {
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
    final titleStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
      fontFamily: 'Satoshi',
      height: 1.25,
    );

    Widget titleWidget;
    if (onTap != null) {
      titleWidget = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: titleStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    } else {
      titleWidget = Text(
        title,
        style: titleStyle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryClr,
        borderRadius: BorderRadius.circular(10.r),
        border: isSelected
            ? Border.all(color: AppColors.buttonClr, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleWidget,
                6.ht,
                CustomText(
                  text: priceText,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonClr,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          12.wd,
          _StoreInvoiceQtyStepper(
            quantity: quantity,
            isSelected: isSelected,
            onRemove: onRemove,
            onAdd: onAdd,
          ),
        ],
      ),
    );
  }
}

/// Minus / qty / plus — compact but still tappable (fits list row on the right).
class _StoreInvoiceQtyStepper extends StatelessWidget {
  final int quantity;
  final bool isSelected;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _StoreInvoiceQtyStepper({
    required this.quantity,
    required this.isSelected,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final btn = 40.h.clamp(36.0, 46.0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isSelected
              ? AppColors.buttonClr.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: btn,
              height: btn,
              child: Center(
                child: Icon(
                  Icons.remove_rounded,
                  size: 22.sp,
                  color: isSelected ? AppColors.buttonClr : Colors.white70,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 30.w,
          child: CustomText(
            text: quantity.toString(),
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            textAlign: TextAlign.center,
          ),
        ),
        Material(
          color: AppColors.buttonClr,
          borderRadius: BorderRadius.circular(8.r),
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8.r),
            splashColor: Colors.black26,
            child: SizedBox(
              width: btn,
              height: btn,
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 22.sp,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

