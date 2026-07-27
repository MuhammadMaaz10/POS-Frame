import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/local_storage/customer_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/item_model.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/add_customer_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/add_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_list_tile.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

class SelectCustomerBottomSheet extends StatefulWidget {
  final HomeScreenController homeController;
  final ValueChanged<CustomerModel> onSelected;

  const SelectCustomerBottomSheet({
    super.key,
    required this.homeController,
    required this.onSelected,
  });

  @override
  State<SelectCustomerBottomSheet> createState() =>
      _SelectCustomerBottomSheetState();
}

class _SelectCustomerBottomSheetState extends State<SelectCustomerBottomSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text);
  }

  void _closeSheet() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final customers = widget.homeController.customerList.where((customer) {
      if (query.isEmpty) return true;
      return customer.name.toLowerCase().contains(query) ||
          customer.email.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: 'Select Customer',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 82.w,
                      child: CustomSmallButton(
                        text: 'Add New',
                        onPressed: () => Get.to(const AddCustomerScreen()),
                      ),
                    ),
                    10.wd,
                    GestureDetector(
                      onTap: _closeSheet,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF172349),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                20.ht,
                CustomTextField(
                  controller: _searchController,
                  hintText: 'Search',
                  prefixIcon: Icons.search,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                ),
                12.ht,
                if (customers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No customers found.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return GestureDetector(
                          onTap: () {
                            widget.onSelected(customer);
                            _closeSheet();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: ItemsCustomListTile(
                              imageUrl: customer.imagePath != null &&
                                      File(customer.imagePath!).existsSync()
                                  ? FileImage(File(customer.imagePath!))
                                  : const AssetImage(AppImages.demo),
                              titleText: customer.name,
                              subTitleText: customer.email,
                              isTrailing: false,
                              leftPadding: 10.w,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectItemsBottomSheet extends StatefulWidget {
  final HomeScreenController homeController;
  final Map<ItemModel, int> initialSelection;
  final ValueChanged<Map<ItemModel, int>> onConfirm;

  const SelectItemsBottomSheet({
    super.key,
    required this.homeController,
    required this.initialSelection,
    required this.onConfirm,
  });

  @override
  State<SelectItemsBottomSheet> createState() => _SelectItemsBottomSheetState();
}

class _SelectItemsBottomSheetState extends State<SelectItemsBottomSheet> {
  late final TextEditingController _searchController;
  late Map<ItemModel, int> _tempSelectedItems;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _tempSelectedItems = Map<ItemModel, int>.from(widget.initialSelection);
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text);
  }

  void _closeSheet() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _toggleItem(ItemModel item) {
    setState(() {
      if (_tempSelectedItems.containsKey(item)) {
        _tempSelectedItems.remove(item);
      } else {
        _tempSelectedItems[item] = 1;
      }
    });
  }

  void _decrementQty(ItemModel item) {
    final quantity = _tempSelectedItems[item] ?? 0;
    setState(() {
      if (quantity > 1) {
        _tempSelectedItems[item] = quantity - 1;
      } else {
        _tempSelectedItems.remove(item);
      }
    });
  }

  void _incrementQty(ItemModel item) {
    final quantity = _tempSelectedItems[item] ?? 0;
    setState(() => _tempSelectedItems[item] = quantity + 1);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;
    final items = widget.homeController.itemList.where((item) {
      if (query.isEmpty) return true;
      return item.itemName.toLowerCase().contains(query) ||
          item.itemCategory.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(
                    text: 'Select Items',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 82.w,
                    child: CustomSmallButton(
                      text: 'Add New',
                      onPressed: () => Get.to(const AddItemScreen()),
                    ),
                  ),
                  10.wd,
                  GestureDetector(
                    onTap: _closeSheet,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF172349),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              20.ht,
              CustomTextField(
                controller: _searchController,
                hintText: 'Search',
                prefixIcon: Icons.search,
                borderColor: Colors.transparent,
                selectedBorderColor: AppColors.buttonClr,
              ),
              12.ht,
              if (items.isEmpty)
                const Center(
                  child: Text(
                    'No items available.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = _tempSelectedItems.containsKey(item);
                      final quantity = _tempSelectedItems[item] ?? 0;

                      return GestureDetector(
                        onTap: () => _toggleItem(item),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF172349),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.buttonClr
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    ItemsCustomListTile(
                                      imageUrl: null,
                                      titleText: item.itemName,
                                      subTitleText: item.itemCategory,
                                      isTrailing: true,
                                      amount: item.unitPrice,
                                      leftPadding: 10.w,
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 5.h,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  _decrementQty(item),
                                              icon: Icon(
                                                Icons.remove_circle_outline,
                                                size: 20.sp,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            CustomText(
                                              text: '$quantity',
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _incrementQty(item),
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                size: 20.sp,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.buttonClr,
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              10.ht,
              CustomButton(
                text: 'Confirm Selection',
                onPressed: () {
                  if (_tempSelectedItems.isNotEmpty) {
                    widget.onConfirm(
                      Map<ItemModel, int>.from(_tempSelectedItems),
                    );
                    _closeSheet();
                  } else {
                    CustomGetSnackBar.show(
                      title: 'No Selection',
                      message: 'Please select at least one item.',
                      backgroundColor: AppColors.buttonClr,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
