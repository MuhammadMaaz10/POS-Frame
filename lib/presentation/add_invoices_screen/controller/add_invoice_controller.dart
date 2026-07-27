import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/local_storage/customer_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/item_model.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/add_customer_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/add_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/home_screen_main.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_list_tile.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../local_storage/invoice_customer.dart';
import '../../../local_storage/invoice_item.dart';
import '../../../local_storage/invoice_model.dart';
import '../../../local_storage/company_model.dart';
import '../../home_screen/controller/home_screen_controller.dart';

class AddInvoicesController extends GetxController {

  /// edit invoice controllers
  var selectedCurrency = 'USD'.obs;  // Default selected
  var editSelectedCurrency = 'USD'.obs;  // Default selected
  var editInvoiceType = 'Fiscal Invoice'.obs;  // Default selected

  final editInvoiceNumber = ''.obs;
  final editSelectedCustomer = Rxn<InvoiceCustomer>();
  RxList<InvoiceItem> editSelectedItem = <InvoiceItem>[].obs;
  final editInvoiceIDController = TextEditingController();
  final editDateController = TextEditingController();
  final editDueDateController = TextEditingController();
  final editNotesController = TextEditingController();
  final editAddressController = TextEditingController();

  /// create invoice controllers
  final invoiceNumber = ''.obs;
  String invoiceNumber2 = '';
  final selectedCustomer = Rxn<CustomerModel>();
  final selectedItem = Rxn<ItemModel>();
  final invoiceIDController = TextEditingController();
  final dateController = TextEditingController();
  final dueDateController = TextEditingController();
  final notesController = TextEditingController();
  final addressController = TextEditingController();

  int _invoiceCounter = 1; // Start from 1, will be loaded from Hive
  int _clientNumber = 1; // Default to 1, will be loaded from CompanyModel

  AddInvoicesController() {
    print("----- on init called ----- ");
    setDefaultInvoiceDates();
    if (AppConstant.isAppConfigured == true){
      print('--- load the invoice number app is configured ---');
    _loadLastInvoiceNumber();
    }else{
      print('--- cannot load the invoice number app is not configured yet---');
    }  // this will generate after load
  }

  /// Defaults Invoice Date and Due Date to today (create invoice).
  void setDefaultInvoiceDates() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    dateController.text = today;
    dueDateController.text = today;
    update();
  }


  /// Refresh client number from company data and regenerate invoice number
  Future<void> refreshClientNumberAndInvoice() async {
    print("🔄 Refreshing client number and invoice number...");
    final newClientNumber = await _loadClientNumber();
    
    // Only refresh if client number has changed
    if (newClientNumber != _clientNumber) {
      print("📋 Client number changed from $_clientNumber to $newClientNumber");
      _clientNumber = newClientNumber;
      
      // Reload invoice number with new client number (this will also regenerate)
      await _loadLastInvoiceNumber();
      update(); // Trigger UI update
    } else {
      // Even if client number hasn't changed, regenerate display to ensure it's correct
      _regenerateInvoiceNumberDisplay();
      update(); // Trigger UI update
      print("📋 Client number unchanged: $_clientNumber, refreshed invoice number display");
    }
  }

  /// Load client number from company data
  Future<int> _loadClientNumber() async {
    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      
      if (username != null) {
        final box = await Hive.openBox<CompanyModel>('companies_$username');
        if (box.isNotEmpty) {
          final company = box.values.first;
          return company.clientNumber;
        }
      }
    } catch (e) {
      print('Error loading client number: $e');
    }
    return 1; // Default to 1 if not found
  }



  var isInvoiceReady = false.obs;
  Future<void> _loadLastInvoiceNumber() async {

    print("isInvoiceReady ---in start-------> ${isInvoiceReady.value}");
    
    // Load client number from company data
    _clientNumber = await _loadClientNumber();
    print("📋 Loaded client number: $_clientNumber");
    
    final prefs = await SharedPreferences.getInstance();
    
    // Use client-specific key for SharedPreferences
    final clientSpecificKey = 'lastInvoiceNumber_client_$_clientNumber';
    AppConstant.lastInvoiceNumber = prefs.getString(clientSpecificKey) ?? "";
    
    // Try to load from old global key for backward compatibility
    if (AppConstant.lastInvoiceNumber.isEmpty) {
      AppConstant.lastInvoiceNumber = prefs.getString('lastInvoiceNumber') ?? "";
    }

    // Parse invoice number - support both old and new formats
    if (AppConstant.lastInvoiceNumber.isNotEmpty) {
      // New format: INV-FR-{clientNumber}-{counter}
      final newFormatRegex = RegExp(r'^INV-FR-(\d+)-(\d+)$');
      final newFormatMatch = newFormatRegex.firstMatch(AppConstant.lastInvoiceNumber);
      
      if (newFormatMatch != null) {
        // New format detected
        final invoiceClientNumber = int.tryParse(newFormatMatch.group(1) ?? '1') ?? 1;
        final counterPart = int.tryParse(newFormatMatch.group(2) ?? '0') ?? 0;
        
        // Only use if it's for the same client
        if (invoiceClientNumber == _clientNumber) {
          _invoiceCounter = counterPart + 1;
          print("📄 Loaded last invoice number (new format): ${AppConstant.lastInvoiceNumber}, counter set to $_invoiceCounter");
        } else {
          _invoiceCounter = 1;
          print("📄 Different client number detected, resetting counter to 1");
        }
      } else if (AppConstant.lastInvoiceNumber.startsWith('INV-FR-')) {
        // Old format: INV-FR-{counter} - migrate to new format
        final numberPart = AppConstant.lastInvoiceNumber.replaceAll('INV-FR-', '');
        final parsed = int.tryParse(numberPart) ?? 0;
        _invoiceCounter = parsed + 1;
        print("📄 Loaded last invoice number (old format, migrating): ${AppConstant.lastInvoiceNumber}, counter set to $_invoiceCounter");
      } else {
        _invoiceCounter = 1;
        print("📄 Invalid format, counter reset to 1");
      }
    } else {
      _invoiceCounter = 1;
      print("📄 No saved invoice number, counter reset to 1");
    }

    // ✅ Now generate after loading (without incrementing counter)
    // Use _regenerateInvoiceNumberDisplay() instead of generateInvoiceNumber()
    // to avoid incrementing the counter during load
    _regenerateInvoiceNumberDisplay();
    isInvoiceReady.value = true;
    print("isInvoiceReady ---at end-------> ${isInvoiceReady.value}");
    // update();
  }


  Future<void> initInvoiceCounter() async {
    // Load client number from company data
    _clientNumber = await _loadClientNumber();
    
    final prefs = await SharedPreferences.getInstance();
    
    // Use client-specific key for SharedPreferences
    final clientSpecificKey = 'lastInvoiceNumber_client_$_clientNumber';
    AppConstant.lastInvoiceNumber = prefs.getString(clientSpecificKey) ?? "";
    
    // Try to load from old global key for backward compatibility
    if (AppConstant.lastInvoiceNumber.isEmpty) {
      AppConstant.lastInvoiceNumber = prefs.getString('lastInvoiceNumber') ?? "";
    }

    // Parse invoice number - support both old and new formats
    if (AppConstant.lastInvoiceNumber.isNotEmpty) {
      // New format: INV-FR-{clientNumber}-{counter}
      final newFormatRegex = RegExp(r'^INV-FR-(\d+)-(\d+)$');
      final newFormatMatch = newFormatRegex.firstMatch(AppConstant.lastInvoiceNumber);
      
      if (newFormatMatch != null) {
        // New format detected
        final invoiceClientNumber = int.tryParse(newFormatMatch.group(1) ?? '1') ?? 1;
        final counterPart = int.tryParse(newFormatMatch.group(2) ?? '0') ?? 0;
        
        // Only use if it's for the same client
        if (invoiceClientNumber == _clientNumber) {
          _invoiceCounter = counterPart + 1;
        } else {
          _invoiceCounter = 1;
        }
      } else if (AppConstant.lastInvoiceNumber.startsWith('INV-FR-')) {
        // Old format: INV-FR-{counter} - migrate to new format
        final numberPart = AppConstant.lastInvoiceNumber.replaceAll('INV-FR-', '');
        final parsed = int.tryParse(numberPart) ?? 0;
        _invoiceCounter = parsed + 1;
      } else {
        _invoiceCounter = 1;
      }
    } else {
      _invoiceCounter = 1; // fallback if no invoice found
    }

    print("🔢 Initialized _invoiceCounter = $_invoiceCounter from lastInvoiceNumber = ${AppConstant.lastInvoiceNumber} (client: $_clientNumber)");
  }



  void generateInvoiceNumber() {
    print("---------- generateInvoiceNumber is called ------------ ");
    
    // New format: INV-FR-{clientNumber}-{counter}
    // Client number should already be loaded in _loadLastInvoiceNumber()
    invoiceNumber.value = 'INV-FR-$_clientNumber-${_invoiceCounter.toString().padLeft(5, '0')}';
    invoiceNumber2 = 'INV-FR-$_clientNumber-${_invoiceCounter.toString().padLeft(5, '0')}';
    print("📋 Generated invoice number: ${invoiceNumber.value}");
    print("📋 Generated invoice number 2: ${invoiceNumber2}");
    invoiceIDController.text = invoiceNumber2;
    // invoiceIDController.text = invoiceNumber.value.toString();
    print("📋 Generated invoice number in controller: ${invoiceIDController.text}");
    update();
    _invoiceCounter++;
    // _saveInvoiceCounter();
  }

  /// Regenerate invoice number display without incrementing counter (for refresh)
  void _regenerateInvoiceNumberDisplay() {
    print("🔄 Regenerating invoice number display (no counter increment)");
    invoiceNumber.value = 'INV-FR-$_clientNumber-${_invoiceCounter.toString().padLeft(5, '0')}';
    invoiceNumber2 = 'INV-FR-$_clientNumber-${_invoiceCounter.toString().padLeft(5, '0')}';
    invoiceIDController.text = invoiceNumber2;
    print("📋 Regenerated invoice number display: ${invoiceNumber.value}");
  }

  // void generateInvoiceNumber() {
  //   invoiceNumber.value = 'INV-FR-${_invoiceCounter.toString().padLeft(5, '0')}';
  //   print("📋 Generated invoice number: ${invoiceNumber.value}");
  //   _invoiceCounter++;
  //   _saveInvoiceCounter();
  // }

  void updateSelectedCurrency(String? value) {
    if (value != null) {
      selectedCurrency.value = value;
      update();
      print("selected currency ---> ${selectedCurrency.value}");
    }
  }

  void editUpdateSelectedCurrency(String? value) {
    if (value != null) {
      editSelectedCurrency.value = value;
      update();
      print("selected currency ---> ${editSelectedCurrency.value}");
    }
  }


  void showCustomerBottomSheet(BuildContext context) {
    final homeController = Get.find<HomeScreenController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select Customer',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 82.w,
                      child: CustomSmallButton(
                        text: "Add New",
                        onPressed: () {
                          Get.to(AddCustomerScreen());
                        },
                      ),
                    ),
                    10.wd,
                    GestureDetector(
                      onTap: () => Get.back(),
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
                Obx(() {
                  final customers = homeController.customerList;

                  if (customers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No customers found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return GestureDetector(
                        onTap: () {
                          selectedCustomer.value = customer; // make sure `selectedCustomer` matches this type
                          print("selected customer TIN number ---> ${customer.tinNumber}");
                          print("selected customer TIN number ---> ${customer.houseNumber}");
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ItemsCustomListTile(
                            imageUrl: customer.imagePath != null && File(customer.imagePath!).existsSync()
                                ? FileImage(File(customer.imagePath!))
                                : AssetImage(AppImages.demo) , // if needed
                            titleText: customer.name,
                            subTitleText: customer.email,
                            isTrailing: false,
                            leftPadding: 10.w,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void showEditCustomerBottomSheet(BuildContext context) {
    final homeController = Get.find<HomeScreenController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select Customer',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 82.w,
                      child: CustomSmallButton(
                        text: "Add New",
                        onPressed: () {
                          Get.to(AddCustomerScreen());
                        },
                      ),
                    ),
                    10.wd,
                    GestureDetector(
                      onTap: () => Get.back(),
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
                Obx(() {
                  final customers = homeController.customerList;

                  if (customers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No customers found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return GestureDetector(
                        onTap: () {
                           editSelectedCustomer.value=InvoiceCustomer(
                               name: customer.name,
                               pic: customer.imagePath ?? AppImages.demo,
                               email: customer.email,
                             tinNumber: customer.tinNumber,
                             vatNumber: customer.vatNumber,  // ✅ ADD THIS
                             phoneNumber: customer.phone,
                             provience: customer.province,
                             city: customer.city,
                             street: customer.street,
                             houseNumber: customer.houseNumber,
                           );

                           print("selected customer TIN number ---> ${customer.tinNumber}");
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ItemsCustomListTile(
                            imageUrl: customer.imagePath != null && File(customer.imagePath!).existsSync()
                                ? FileImage(File(customer.imagePath!))
                                : AssetImage(AppImages.demo) , // if needed
                            titleText: customer.name,
                            subTitleText: customer.email,
                            isTrailing: false,
                            leftPadding: 10.w,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  final RxList<ItemModel> selectedItems = <ItemModel>[].obs;// Assuming ItemModel is the correct data model
   RxMap<ItemModel, int> selectedItemsWithQuantity = <ItemModel, int>{}.obs;
  /// select multiple items
   void showItemBottomSheet(BuildContext context) {
    final homeController = Get.find<HomeScreenController>();
    // Use ItemModel instead of Item to match the type in homeController.itemList
    // final RxList<ItemModel> selectedItems = <ItemModel>[].obs; // For compatibility
    // Map to store item quantities
    final RxMap<ItemModel, int> tempSelectedItems =
        Map<ItemModel, int>.from(selectedItemsWithQuantity).obs;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select Items',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 82.w,
                      child: CustomSmallButton(
                        text: "Add New",
                        onPressed: () {
                          Get.to(AddItemScreen());
                        },
                      ),
                    ),
                    10.wd,
                    GestureDetector(
                      onTap: () => Get.back(),
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
            
                /// Item list with your widgets
                Obx(() {
                  if (homeController.itemList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items available.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
            
                  return Expanded(
                    child: ListView.builder(
                      itemCount: homeController.itemList.length,
                      itemBuilder: (context, index) {
                        final item = homeController.itemList[index];
            
            
            
                        return Obx((){
                          final isSelected = tempSelectedItems.containsKey(item);
                          final quantity = tempSelectedItems[item] ?? 0;
                          return GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                tempSelectedItems.remove(item);
                                selectedItems.remove(item);
                              } else {
                                tempSelectedItems[item] = 1;// Default quantity
                                selectedItems.add(item);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF172349),
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
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (quantity > 1) {
                                                      tempSelectedItems[item] = quantity - 1;
                                                    } else {
                                                      tempSelectedItems.remove(item);
                                                    }
                                                  },
                                                  icon: Icon(Icons.remove_circle_outline, size: 20.sp, color: Colors.white70),
                                                ),
                                                CustomText(
                                                  text: '$quantity',
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    tempSelectedItems[item] = quantity + 1;
                                                  },
                                                  icon: Icon(Icons.add_circle_outline, size: 20.sp, color: Colors.white70),
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
                        }
                        );
            
            
                      },
                    ),
                  );
                }),
            
                10.ht,
            
                /// Confirm button
                CustomButton(
                  text: "Confirm Selection",
                  onPressed: () {
                    if (tempSelectedItems.isNotEmpty) {
                      selectedItemsWithQuantity.assignAll(tempSelectedItems);
                      Get.back();
                    } else {
                      CustomGetSnackBar.show(
                        title: "No Selection",
                        message: "Please select at least one item.",
                        backgroundColor: AppColors.buttonClr,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// update multiple items
  void showEditItemBottomSheet(BuildContext context) {
    final homeController = Get.find<HomeScreenController>();

    // Initialize temporary map with current editSelectedItem quantities
    final RxMap<ItemModel, int> tempSelectedItems = <ItemModel, int>{}.obs;
    for (var invoiceItem in editSelectedItem) {
      final matchingItem = homeController.itemList.firstWhereOrNull(
            (item) => item.itemName == invoiceItem.name && item.itemCategory == invoiceItem.category,
      );
      if (matchingItem != null) {
        tempSelectedItems[matchingItem] = invoiceItem.quantity;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select Items',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 82.w,
                      child: CustomSmallButton(
                        text: "Add New",
                        onPressed: () {
                          Get.to(() => AddItemScreen());
                        },
                      ),
                    ),
                    10.wd,
                    GestureDetector(
                      onTap: () => Get.back(),
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
            
                // Item list
                Obx(() {
                  if (homeController.itemList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items available.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
            
                  return Expanded(
                    child: ListView.builder(
                      itemCount: homeController.itemList.length,
                      itemBuilder: (context, index) {
                        final item = homeController.itemList[index];
                        return Obx(() {
                          final isSelected = tempSelectedItems.containsKey(item);
                          final quantity = tempSelectedItems[item] ?? 0;
                          return GestureDetector(
                            onTap: () {
                              if (isSelected) {
                                tempSelectedItems.remove(item);
                              } else {
                                tempSelectedItems[item] = 1; // Default quantity
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF172349),
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
                                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (quantity > 1) {
                                                      tempSelectedItems[item] = quantity - 1;
                                                    } else {
                                                      tempSelectedItems.remove(item);
                                                    }
                                                  },
                                                  icon: Icon(Icons.remove_circle_outline, size: 20.sp, color: Colors.white70),
                                                ),
                                                CustomText(
                                                  text: '$quantity',
                                                  fontSize: 16.sp,
                                                  color: Colors.white,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    tempSelectedItems[item] = quantity + 1;
                                                  },
                                                  icon: Icon(Icons.add_circle_outline, size: 20.sp, color: Colors.white70),
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
                        });
                      },
                    ),
                  );
                }),
            
                10.ht,
            
                // Confirm button
                CustomButton(
                  text: "Confirm Selection",
                  onPressed: () {
                    if (tempSelectedItems.isNotEmpty) {
                      // Update editSelectedItem with selected items and quantities
                      editSelectedItem.value = tempSelectedItems.entries.map((entry) {
                        final item = entry.key;
                        final quantity = entry.value;
                        return InvoiceItem(
                          name: item.itemName,
                          category: item.itemCategory,
                          price: item.unitPrice.toString(), // Store unit price
                          quantity: quantity,
                          taxName: item.vatCategoryName,
                          taxPercentage: item.vatCategoryPercentage,
                          taxID: item.vatCategoryID,
                          hsCode: item.hsCode
                        );
                      }).toList();
                      // Update editSelectedItemsWithQuantity
                      selectedItemsWithQuantity.assignAll(tempSelectedItems);
                      Get.back();
                    } else {
                      CustomGetSnackBar.show(
                        title: "No Selection",
                        message: "Please select at least one item.",
                        backgroundColor: AppColors.buttonClr,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }




// Reactive quantity for each item
  var quantity = 1.obs; // Default quantity is 1
  double unitPrice = 0; // Unit price of the item

  double get totalPrice => unitPrice * quantity.value;

  // Increment quantity
  void incrementQuantity() {
    quantity.value++;
  }

  // Decrement quantity (minimum 1)
  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }


  /// select item Quantity
  void showItemQuantityBottomSheet(BuildContext context) {
    final homeController = Get.find<HomeScreenController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Select Quantity',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
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

                // Reactive List of Items
                Obx(() {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: homeController.itemList.length,
                    itemBuilder: (context, index) {
                      final item = homeController.itemList[index];
                      unitPrice = item.unitPrice;

                      return GestureDetector(
                        onTap: () {
                          // selectedItem.value = item;
                          // Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Container(
                            // height: 57.h,
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF172349),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Main content (item name and unit price)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 0.h),
                                      Text(
                                        "\$${item.unitPrice} x ${quantity.value}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.smallTextClr,
                                          fontFamily: "Satoshi",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Trailing content (quantity controls and total price)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      // width: 90.w,
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.5.h),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(color: Color(0xFF343A40)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => decrementQuantity(),
                                            child: Icon(Icons.remove, color: Colors.white, size: 20.sp),
                                          ),
                                          SizedBox(width: 10.w),
                                          Obx(() => Text(
                                            "${quantity.value}",
                                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                          )),
                                          SizedBox(width: 10.w),
                                          GestureDetector(
                                            onTap: () => incrementQuantity(),
                                            child: Icon(Icons.add, color: Colors.white, size: 20.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Obx(() => Text(
                                      "\$${totalPrice.toStringAsFixed(1)}",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        ),
                      );
                    },
                  );
                }),
                30.ht,
                CustomButton(text: "Confirm", onPressed: () {
                },),
                // 20.ht,
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> createAndSaveInvoice({
    required String invoiceNo,
    required String customerName,
    required String customerPic,
    required String customerEmail,
    required String customerTinNumber,
    String? customerVatNumber,  // ✅ ADD THIS
    required String customerPhoneNumber,
    required String customerProvinceNumber,
    required String customerCityNumber,
    required String customerStreetNumber,
    required String customerHouseNumber,
    required List<InvoiceItem> items,
    required String invoiceDate,
    required String invoiceDueDate,
    required String notes,
    required String termsAndConditions,
  })
  async {
    // Create InvoiceCustomer
    final customer = InvoiceCustomer(
      name: customerName,
      pic: customerPic,
      email: customerEmail,
      tinNumber: customerTinNumber,
      vatNumber: customerVatNumber,  // ✅ ADD THIS
      phoneNumber:customerPhoneNumber,
      provience: customerProvinceNumber,
      city: customerCityNumber,
      street: customerStreetNumber,
      houseNumber: customerHouseNumber,
    );




    // Create InvoiceModel
    final invoice = InvoiceModel(
      invoiceNo: invoiceNo,
      customer: customer,
      items: items,
      invoiceDate: invoiceDate,
      invoiceDueDate: invoiceDueDate,
      notes: notes,
      termsAndConditions: termsAndConditions,
      currency: selectedCurrency.toString(),
      invoiceType: "FiscalInvoice",
      qrUrl: null,
    );

    // Save to Hive box
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<InvoiceModel>('invoices_$username');
    await box.add(invoice);
  }



  Future<void> selectDate(BuildContext context,
      {required bool isInvoiceDate})
  async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.buttonClr,
              onPrimary: Colors.white,
              surface: AppColors.secondaryClr,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.bgClr,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isInvoiceDate) {
        dateController.text = formattedDate;
        update();
      } else {
        dueDateController.text = formattedDate;
        update();
      }
    }
  }


  /// Guards against duplicate Generate Invoice taps.
  final isGeneratingInvoice = false.obs;

  ///////////////// create invoice //////////////////
  Future<void> createInvoice() async {
    if (isGeneratingInvoice.value) return;

    if (selectedCustomer.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a customer",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (dateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select an invoice date",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (dueDateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a due date",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isGeneratingInvoice.value = true;
    update();

    final createdInvoiceNo = invoiceNumber.value;
    final selectedItems = selectedItemsWithQuantity.entries.map((entry) {
      return InvoiceItem(
        name: entry.key.itemName,
        category: entry.key.itemCategory,
        price: (entry.key.unitPrice * entry.value).toString(),
        quantity: entry.value,
        taxName: entry.key.vatCategoryName,
        taxPercentage: entry.key.vatCategoryPercentage,
        taxID: entry.key.vatCategoryID,
        hsCode: entry.key.hsCode,
      );
    }).toList();

    try {
      // 1) Always save locally first (online + offline)
      await createAndSaveInvoice(
        invoiceNo: createdInvoiceNo,
        customerName: selectedCustomer.value!.name,
        customerPic: selectedCustomer.value!.imagePath!,
        customerEmail: selectedCustomer.value!.email,
        customerPhoneNumber: selectedCustomer.value!.phone,
        customerProvinceNumber: selectedCustomer.value!.province,
        customerCityNumber: selectedCustomer.value!.city,
        customerStreetNumber: selectedCustomer.value!.street,
        customerHouseNumber: selectedCustomer.value!.houseNumber,
        customerTinNumber: selectedCustomer.value!.tinNumber,
        customerVatNumber: selectedCustomer.value!.vatNumber,
        items: selectedItems,
        invoiceDate: dateController.text,
        invoiceDueDate: dueDateController.text,
        notes: notesController.text,
        termsAndConditions: addressController.text,
      );

      await saveLastInvoiceNumber(createdInvoiceNo);
      generateInvoiceNumber();

      _resetCreateInvoiceForm();

      // 2) Navigate home so invoice is visible (Pending until backend succeeds)
      Get.offAll(() => const HomeScreenMain());

      // CRITICAL: after offAll, always use the live HomeScreenController
      // (stale reference was leaving online invoices stuck on Pending in the UI).
      await Future.delayed(const Duration(milliseconds: 300));
      if (!Get.isRegistered<HomeScreenController>()) {
        Get.put(HomeScreenController(), permanent: true);
      }
      final homeController = Get.find<HomeScreenController>();
      await homeController.loadInvoice();

      CustomGetSnackBar.show(
        title: "Success",
        message: 'Invoice $createdInvoiceNo generated successfully!',
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );

      final hasNet = await homeController.hasInternetConnection();
      if (!hasNet) {
        // Offline: local Pending invoice only — existing behavior
        return;
      }

      // 3) Online: process/upload with cancellable dialog
      await _processGeneratedInvoiceOnline(
        createdInvoiceNo: createdInvoiceNo,
      );
    } catch (e) {
      print('🔥 createInvoice error: $e');
      CustomGetSnackBar.show(
        title: "Error",
        message: 'Failed to generate invoice: $e',
        backgroundColor: AppColors.redClr,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isGeneratingInvoice.value = false;
      update();
    }
  }

  void _resetCreateInvoiceForm() {
    selectedCustomer.value = null;
    selectedItem.value = null;
    selectedItemsWithQuantity.clear();
    invoiceIDController.clear();
    notesController.clear();
    addressController.clear();
    setDefaultInvoiceDates();
  }

  /// Online-only: upload local invoice, update to Processed on success, open preview.
  /// Close cancels upload only — invoice stays Pending on Home.
  Future<void> _processGeneratedInvoiceOnline({
    required String createdInvoiceNo,
  }) async {
    HomeScreenController home() => Get.find<HomeScreenController>();

    while (true) {
      final cancelToken = ReceiptUploadCancelToken();
      var dialogOpen = true;

      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF000D3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      cancelToken.cancel();
                      if (dialogOpen &&
                          (Get.isDialogOpen == true || Get.overlayContext != null)) {
                        dialogOpen = false;
                        if (Get.overlayContext != null) {
                          Navigator.of(Get.overlayContext!).pop();
                        } else {
                          Get.back();
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF172349),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "Invoice processing to the backend...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final homeController = home();
      await homeController.loadInvoice();
      var index = homeController.filteredInvoiceList
          .indexWhere((i) => i.invoiceNo == createdInvoiceNo);
      if (index < 0) index = 0;

      final invoice = homeController.filteredInvoiceList[index];
      final ok = await homeController.createReceipt(
        invoiceModel: invoice,
        index: index,
        cancelToken: cancelToken,
        showErrors: false,
      );

      if (cancelToken.isCancelled) {
        print('⏹ Backend processing cancelled for $createdInvoiceNo — Pending');
        await home().loadInvoice();
        return;
      }

      if (dialogOpen && (Get.isDialogOpen == true || Get.overlayContext != null)) {
        dialogOpen = false;
        if (Get.overlayContext != null) {
          Navigator.of(Get.overlayContext!).pop();
        } else if (Get.isDialogOpen == true) {
          Get.back();
        }
      }

      if (ok && HomeScreenController.hasValidQr(invoice.qrUrl)) {
        // Persist Processed on the Hive record for this invoice number
        var settingsBox = await Hive.openBox('settings');
        var username = settingsBox.get('loggedInUser');
        final invoiceBox = Hive.box<InvoiceModel>('invoices_$username');
        final qr = invoice.qrUrl.toString();

        InvoiceModel? hiveInvoice;
        for (final inv in invoiceBox.values) {
          if (inv.invoiceNo == createdInvoiceNo) {
            hiveInvoice = inv;
            break;
          }
        }
        if (hiveInvoice != null) {
          hiveInvoice.qrUrl = qr;
          await hiveInvoice.save();
          print('✅ Hive invoice $createdInvoiceNo marked Processed with qrUrl');
        } else {
          await invoiceBox.put(invoice.key, invoice);
          print('✅ Fallback put for $createdInvoiceNo with qrUrl');
        }

        final live = home();
        if (username != null) {
          // Rebuild qr list from invoices after save
          await live.loadInvoice();
          await live.saveQrUrlsToHive(username, live.qrUrlList);
        }
        await live.saveQrUrls(live.qrUrlList);
        await live.loadInvoice();
        live.invoiceList.refresh();
        live.filteredInvoiceList.refresh();
        live.qrUrlList.refresh();

        final previewIndex = live.filteredInvoiceList
            .indexWhere((i) => i.invoiceNo == createdInvoiceNo);
        final previewInvoice = previewIndex >= 0
            ? live.filteredInvoiceList[previewIndex]
            : invoice;

        await Future.delayed(const Duration(milliseconds: 100));
        await live.invoicePreview(
          invoiceModel: previewInvoice,
          index: previewIndex >= 0 ? previewIndex : index,
          qrUrl: qr,
        );

        // After preview closes, force UI refresh on the live home controller
        if (Get.isRegistered<HomeScreenController>()) {
          await home().loadInvoice();
          home().filteredInvoiceList.refresh();
          home().qrUrlList.refresh();
        }
        return;
      }

      // Backend failure — Pending + Retry / Close
      final ctx = Get.overlayContext ?? Get.context;
      String? action;
      if (ctx != null) {
        action = await showDialog<String>(
          context: ctx,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF000D3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              'Processing failed',
              style: TextStyle(color: Colors.white, fontFamily: 'Satoshi'),
            ),
            content: const Text(
              'Invoice is saved locally as Pending. You can retry now or close and sync later.',
              style: TextStyle(color: Colors.white70, fontFamily: 'Satoshi'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('close'),
                child: const Text('Close', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('retry'),
                child: const Text('Retry', style: TextStyle(color: AppColors.buttonClr)),
              ),
            ],
          ),
        );
      }

      await home().loadInvoice();
      if (action == 'retry') {
        continue;
      }
      return;
    }
  }


  /// saving new invoice number when invoice generate successfully
  Future<void> saveLastInvoiceNumber(String invoiceNumber) async {
    // Ensure client number is loaded
    if (_clientNumber == 1) {
      _clientNumber = await _loadClientNumber();
    }
    
    final prefs = await SharedPreferences.getInstance();
    AppConstant.lastInvoiceNumber = invoiceNumber; // update global variable
    
    // Save with client-specific key
    final clientSpecificKey = 'lastInvoiceNumber_client_$_clientNumber';
    await prefs.setString(clientSpecificKey, AppConstant.lastInvoiceNumber);
    print("💾 Saved lastInvoiceNumber for client $_clientNumber: ${AppConstant.lastInvoiceNumber}");
    
    // Don't call _loadLastInvoiceNumber() here to avoid double generation
    // The counter is already incremented in generateInvoiceNumber()
  }



  late int editIndexInvoice;
  String? editOriginalInvoiceNo; // Add this to store the original invoice's originalInvoiceNo

  /////////////////////// edit invoice //////////////////////////////
  Future<void> saveEditedInvoice() async {
    if (editSelectedCustomer.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a customer",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (editDateController.text.isEmpty || editDueDateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select invoice and due dates",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Get logged in user's invoice box
    final settingsBox = await Hive.openBox('settings');
    final username = settingsBox.get('loggedInUser');
    final invoiceBox = await Hive.openBox<InvoiceModel>('invoices_$username');


    if ( editIndexInvoice < 0) {
      CustomGetSnackBar.show(
        title: "Error",
        message: "Invalid invoice reference",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Build updated data
    final updatedCustomer = InvoiceCustomer(
      name: editSelectedCustomer.value!.name,
      pic: editSelectedCustomer.value!.pic,
      email: editSelectedCustomer.value!.email,
      tinNumber: editSelectedCustomer.value!.tinNumber,
      vatNumber: editSelectedCustomer.value!.vatNumber,
      phoneNumber: editSelectedCustomer.value!.phoneNumber,
      provience: editSelectedCustomer.value!.provience,
      city: editSelectedCustomer.value!.city,
      street: editSelectedCustomer.value!.street,
      houseNumber: editSelectedCustomer.value!.houseNumber,
    );

    if (selectedItemsWithQuantity.isEmpty) {
      editSelectedItem.value = editSelectedItem.value;  // retain the existing data
    } else {
       editSelectedItem.value = selectedItemsWithQuantity.entries.map((entry) {
        return InvoiceItem(
          name: entry.key.itemName,
          category: entry.key.itemCategory,
          price: (entry.key.unitPrice * entry.value).toString(), // total price
          quantity: entry.value,
          taxName: entry.key.vatCategoryName,
          taxPercentage: entry.key.vatCategoryPercentage,
          taxID: entry.key.vatCategoryID,
          hsCode: entry.key.hsCode,
        );
      }).toList();
    }

    // Get the original invoice to preserve its originalInvoiceNo
    final existingInvoice = invoiceBox.getAt(editIndexInvoice);
    
    final updatedInvoice = InvoiceModel(
      invoiceNo: editInvoiceNumber.value,
      customer: updatedCustomer,
      items: editSelectedItem.value,
      invoiceDate: editDateController.text,
      invoiceDueDate: editDueDateController.text,
      notes: editNotesController.text,
      termsAndConditions: editAddressController.text,
      currency: editSelectedCurrency.value,
      invoiceType: editInvoiceType.toString(),
      originalInvoiceNo: existingInvoice?.originalInvoiceNo ?? editInvoiceNumber.value, // Preserve original, or use current for normal invoices
    );


    // Update in Hive
    await invoiceBox.putAt(editIndexInvoice, updatedInvoice);

    // Reload and notify
    Get.find<HomeScreenController>().loadInvoice();
    Get.back();
    selectedItemsWithQuantity.clear();

    CustomGetSnackBar.show(
      title: "Success",
      message: "Invoice updated successfully!",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );
  }


  Future<void> deleteInvoice() async {


    // Get logged in user's invoice box
    final settingsBox = await Hive.openBox('settings');
    final username = settingsBox.get('loggedInUser');
    final invoiceBox = await Hive.openBox<InvoiceModel>('invoices_$username');


    if ( editIndexInvoice < 0) {
      CustomGetSnackBar.show(
        title: "Error",
        message: "Invalid invoice reference",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Update in Hive
    await invoiceBox.deleteAt(editIndexInvoice,);

    // Reload and notify
    Get.find<HomeScreenController>().loadInvoice();
    Get.back();

    CustomGetSnackBar.show(
      title: "Success",
      message: "Invoice Deleted successfully!",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );
  }


  //////////////////////////////////////////////////////////////////////////////////
/// Duplicate Invoice Function
  /// Additional for duplicate logic
  var originalTotal = 0.0.obs;

  // Initialize invoice for editing
  void initializeEditInvoice(InvoiceModel invoice, int index) {
    editIndexInvoice = index;
    editInvoiceNumber.value = invoice.invoiceNo;
    editSelectedCustomer.value = invoice.customer;
    editSelectedItem.value = invoice.items;
    editDateController.text = invoice.invoiceDate;
    editDueDateController.text = invoice.invoiceDueDate;
    editNotesController.text = invoice.notes ?? '';
    editAddressController.text = invoice.termsAndConditions ?? '';
    editSelectedCurrency.value = invoice.currency ?? 'USD';
    editOriginalInvoiceNo = invoice.originalInvoiceNo; // Store the original invoice's originalInvoiceNo


    print("📝 this function is calling again and again");


    // Load original total
    loadOriginalTotal(invoice);

    // Initialize selectedItemsWithQuantity for editing
    selectedItemsWithQuantity.clear();
    for (var item in invoice.items) {
      final matchingItem = Get.find<HomeScreenController>().itemList.firstWhereOrNull(
            (i) => i.itemName == item.name && i.itemCategory == item.category,
      );
      if (matchingItem != null) {
        selectedItemsWithQuantity[matchingItem] = item.quantity;
      }
    }
    print("📝 Initialized edit invoice: ${invoice.invoiceNo}, items: ${invoice.items.length}");
  }

  void loadOriginalTotal(InvoiceModel invoice) {
    originalTotal.value = invoice.items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.price) ?? 0.0);
    });
    print("💸 Loaded original total: ${originalTotal.value} for invoice: ${invoice.invoiceNo}");
  }

  Future<void> duplicateInvoice() async {
    if (editSelectedCustomer.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a customer",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (editDateController.text.isEmpty || editDueDateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select invoice and due dates",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Generate new invoice number
    // generateInvoiceNumber(); // Reuse existing method to get new number
    String newInvoiceNo = invoiceNumber.value;
    print("📋 Generated new invoice number for duplicate: $newInvoiceNo");

    // Build updated items (from edits)
    if (selectedItemsWithQuantity.isNotEmpty) {
      editSelectedItem.value = selectedItemsWithQuantity.entries.map((entry) {
        return InvoiceItem(
          name: entry.key.itemName,
          category: entry.key.itemCategory,
          price: (entry.key.unitPrice * entry.value).toString(),
          quantity: entry.value,
          taxName: entry.key.vatCategoryName,
          taxPercentage: entry.key.vatCategoryPercentage,
          taxID: entry.key.vatCategoryID,
          hsCode: entry.key.hsCode,
        );
      }).toList();
    }

    // Calculate new total
    double newTotal = editSelectedItem.fold(0.0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0));
    print("💸 New total after edits: $newTotal (original: ${originalTotal.value})");

    // Determine InvoiceType based on comparison or user choice when unchanged
    String newInvoiceType = "FiscalInvoice";
    if (newTotal > originalTotal.value) {
      newInvoiceType = "DebitNote";
      print("📈 Invoice type set to Debit (increase in total)");
    } else if (newTotal < originalTotal.value) {
      newInvoiceType = "CreditNote";
      print("📉 Invoice type set to Credit (decrease in total)");
    } else {
      // No change in total: ask user to choose Credit or Debit Note instead of defaulting to Fiscal Invoice
      final String? userChoice = await Get.dialog<String>(
        barrierDismissible: false,
        AlertDialog(
          backgroundColor: const Color(0xFF000D3A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Invoice type",
            style: TextStyle(fontFamily: 'Satoshi', color: Colors.white),
          ),
          content: const Text(
            "You didn't change the invoice. Do you want to create a Credit Note or Debit Note?",
            style: TextStyle(fontFamily: 'Satoshi', color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Get.back(result: 'CreditNote'),
              child: Text("Credit Note", style: TextStyle(color: AppColors.buttonClr)),
            ),
            TextButton(
              onPressed: () => Get.back(result: 'DebitNote'),
              child: Text("Debit Note", style: TextStyle(color: AppColors.buttonClr)),
            ),
          ],
        ),
      );
      if (userChoice == null) {
        return; // User cancelled
      }
      newInvoiceType = userChoice;
      print("📋 User selected invoice type: $newInvoiceType (no change in total)");
    }

    // Build new customer
    final newCustomer = InvoiceCustomer(
      name: editSelectedCustomer.value!.name,
      pic: editSelectedCustomer.value!.pic,
      email: editSelectedCustomer.value!.email,
      tinNumber: editSelectedCustomer.value!.tinNumber,
      vatNumber: editSelectedCustomer.value!.vatNumber,  // ✅ ADD THIS
      phoneNumber: editSelectedCustomer.value!.phoneNumber,
      provience: editSelectedCustomer.value!.provience,
      city: editSelectedCustomer.value!.city,
      street: editSelectedCustomer.value!.street,
      houseNumber: editSelectedCustomer.value!.houseNumber,
    );

    print("edit notes -----> ${editNotesController.text}");
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("today date ----> $todayDate");

    // Create new InvoiceModel (with null qrUrl)
    final newInvoice = InvoiceModel(
      invoiceNo: newInvoiceNo,
      customer: newCustomer,
      items: editSelectedItem.value,
      invoiceDate: todayDate,
      invoiceDueDate: editDueDateController.text,
      notes: editNotesController.text,
      termsAndConditions: editAddressController.text,
      currency: editSelectedCurrency.value,
      invoiceType: newInvoiceType,
      qrUrl: null, // Explicitly set to null
      originalInvoiceNo: (newInvoiceType == "CreditNote" || newInvoiceType == "DebitNote") 
          ? editOriginalInvoiceNo ?? editInvoiceNumber.value  // Use original invoice number for credit/debit notes
          : newInvoiceNo, // For normal invoices, same as invoice number
    );

    // Save to Hive
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final invoiceBox = Hive.box<InvoiceModel>('invoices_$username');
    await invoiceBox.add(newInvoice);
    print("✅ Saved new duplicate invoice $newInvoiceNo with type $newInvoiceType and qrUrl: null");

    // ✅ Save last invoice number for persistence
    saveLastInvoiceNumber(newInvoiceNo);

    print("✅ Saved duplicate invoice $newInvoiceNo");

    // ✅ Generate the next invoice number immediately
    // generateInvoiceNumber();



    // Reload invoices
    Get.find<HomeScreenController>().loadInvoice();
    Get.offAll(HomeScreenMain());
    selectedItemsWithQuantity.clear();

    CustomGetSnackBar.show(
      title: "Success",
      message: "Duplicate invoice $newInvoiceNo created successfully!",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );


  }




}

