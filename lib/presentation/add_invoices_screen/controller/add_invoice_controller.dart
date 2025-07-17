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
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_list_tile.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../local_storage/invoice_customer.dart';
import '../../../local_storage/invoice_item.dart';
import '../../../local_storage/invoice_model.dart';
import '../../home_screen/controller/home_screen_controller.dart';

class AddInvoicesController extends GetxController {

  /// edit invoice controllers
  var selectedCurrency = 'USD'.obs;  // Default selected
  var editSelectedCurrency = 'USD'.obs;  // Default selected

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
  final selectedCustomer = Rxn<CustomerModel>();
  final selectedItem = Rxn<ItemModel>();
  final invoiceIDController = TextEditingController();
  final dateController = TextEditingController();
  final dueDateController = TextEditingController();
  final notesController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    generateInvoiceNumber();
  }

  Future<void> createReceipt() async {
    try {
      print('Starting receipt creation process...');

      var headers = {
        'Content-Type': 'application/json',
        'apiKey': 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7'
      };

      String url = 'http://frame-server.af-south-1.elasticbeanstalk.com/api/v1/client/receipts/25811';
      var request = http.Request(
        'POST', Uri.parse(url),
      );

      print("createReceipt API Url ---> ${url} ");
      request.body = jsonEncode({
        "receiptType": "FiscalInvoice",
        "receiptCurrency": "USD",
        "receiptGlobalNo": 1,
        "invoiceNo": "INV-5526",
        "buyerData": {
          "buyerRegisterName": "Akim Malaba",
          "buyerTIN": "1234567890",
          "buyerAddress": {
            "houseNumber": "123",
            "street": "Cuddin",
            "city": "Bulawayo",
            "province": "Bulawayo"
          }
        },
        "receiptLinesTaxInclusive": true,
        "receiptLines": [
          {
            "receiptLineHSCode": "99001000",
            "receiptLineType": "Sale",
            "receiptLineNo": 1,
            "receiptLineName": "Sub catchment levy",
            "receiptLineQuantity": 1.0,
            "receiptLineTotal": 12.0,
            "taxPercent": 15,
            "taxID": 3
          },
          {
            "receiptLineHSCode": "99001000",
            "receiptLineType": "Sale",
            "receiptLineNo": 2,
            "receiptLineName": "Water Fund",
            "receiptLineQuantity": 1.0,
            "receiptLineTotal": 12.0,
            "taxPercent": 0,
            "taxID": 2
          },
        ],
        "receiptPayments": [
          {
            "moneyTypeCode": "CASH",
            "paymentAmount": 48.0
          }
        ],
        "receiptTotal": 48.0,
        "receiptTaxAmount": 1.57,
        "receiptPrintForm": "InvoiceA4"
      });


      request.headers.addAll(headers);
      print("Request Body ---> ${request.body}");
      // print('Sending POST request to create receipt...');

      http.StreamedResponse response = await request.send();
      print('Response received with status code: ${response.statusCode}');

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print('Receipt created successfully: $responseBody');
        Get.snackbar(
          'Success',
          'Receipt created successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } else {
        String errorMessage = response.reasonPhrase ?? 'Unknown error';
        print('Failed to create receipt: $errorMessage');
        Get.snackbar(
          'Error',
          'Failed to create receipt: $errorMessage',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error occurred while creating receipt: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  int _invoiceCounter = 1; // start from 1

  void generateInvoiceNumber() {
    invoiceNumber.value = 'INV-FR-${_invoiceCounter.toString().padLeft(5, '0')}';
    _invoiceCounter++;
  }

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
      currency: selectedCurrency.toString()
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
      } else {
        dueDateController.text = formattedDate;
      }
    }
  }

  void generateInvoice() {
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
    final selectedItems = selectedItemsWithQuantity.entries.map((entry) {
      return InvoiceItem(
        name: entry.key.itemName,
        category: entry.key.itemCategory,
        price: (entry.key.unitPrice * entry.value).toString(), // total price = unit × quantity
        quantity: entry.value,
        taxName: entry.key.vatCategoryName,
        taxPercentage: entry.key.vatCategoryPercentage,
        taxID: entry.key.vatCategoryID,
          hsCode: entry.key.hsCode

      );
    }).toList();


    createAndSaveInvoice(
      invoiceNo: invoiceNumber.value,
      customerName: selectedCustomer.value!.name,
      customerPic: selectedCustomer.value!.imagePath!,
      customerEmail: selectedCustomer.value!.email,
      customerPhoneNumber: selectedCustomer.value!.phone,
      customerProvinceNumber: selectedCustomer.value!.province,
      customerCityNumber: selectedCustomer.value!.city,
      customerStreetNumber: selectedCustomer.value!.street,
      customerHouseNumber: selectedCustomer.value!.houseNumber,
      customerTinNumber: selectedCustomer.value!.tinNumber,
      items: selectedItems,
      invoiceDate: dateController.text,
      invoiceDueDate: dueDateController.text,
      notes: notesController.text,
      termsAndConditions: addressController.text,
    );

    Get.find<HomeScreenController>().loadInvoice();

    Get.back();
    // Simulate invoice generation
    CustomGetSnackBar.show(
      title: "Success",
      message: 'Invoice ${invoiceNumber.value} generated successfully!',
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );


    // Reset fields after submission
    generateInvoiceNumber();
    selectedCustomer.value = null;
    selectedItem.value = null;
    dateController.clear();
    dueDateController.clear();
    notesController.clear();
    addressController.clear();
  }

  late int editIndexInvoice;


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


    final updatedInvoice = InvoiceModel(
      invoiceNo: editInvoiceNumber.value,
      customer: updatedCustomer,
      items: editSelectedItem.value,
      invoiceDate: editDateController.text,
      invoiceDueDate: editDueDateController.text,
      notes: editNotesController.text,
      termsAndConditions: editAddressController.text,
      currency: editSelectedCurrency.toString()
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

}

class ReceiptController with ChangeNotifier {
  bool loading = false;

  Future<void> updateLoading(bool value) async {
    loading = value;
    notifyListeners();
  }

  Future<void> createReceipt({required InvoiceModel invoiceModel}) async {
    await updateLoading(true);

    try {
      print('Starting receipt creation process...');

      var headers = {
        'Content-Type': 'application/json',
        'apiKey': 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7'
      };

      String url =
          'http://frame-server.af-south-1.elasticbeanstalk.com/api/v1/client/receipts/25811';
      var request = http.Request('POST', Uri.parse(url));

      // Build receipt lines from invoice items
      List<Map<String, dynamic>> receiptLines = [];

      for (int i = 0; i < invoiceModel.items.length; i++) {
        final item = invoiceModel.items[i];
        print('Hs Code ... ${item.hsCode}');
        print('item.name ... ${item.name}');
        receiptLines.add({
          "receiptLineHSCode": item.hsCode ?? "99001000",
          "receiptLineType": "Sale",
          "receiptLineNo": i + 1,
          "receiptLineName": item.name,
          "receiptLineQuantity": item.quantity is String
              ? double.tryParse(item.quantity) ?? 1.0
              : item.quantity.toDouble(),
          "receiptLineTotal": double.tryParse(item.price) ?? 0.0,
          "taxPercent": item.taxPercentage is String
              ? double.tryParse(item.taxPercentage) ?? 0
              : item.taxPercentage,
          "taxID": item.taxID ?? 2,
        });

      }



      // Extract customer info
      final buyerData = {
        "buyerRegisterName": invoiceModel.customer.name,
        "buyerTIN": invoiceModel.customer.tinNumber ?? "0000000000",
        "buyerAddress": {
          "houseNumber": invoiceModel.customer.houseNumber,
          "street": invoiceModel.customer.street,
          "city": invoiceModel.customer.city,
          "province": invoiceModel.customer.provience,
        }
      };

      // Calculate totals
      double receiptTotal = _calculateTotal(invoiceModel);
      double receiptTaxAmount = _calculateTax(invoiceModel);

      // Final body
      request.body = jsonEncode({
        "receiptType": "FiscalInvoice",
        "receiptCurrency": "USD",
        "receiptGlobalNo": 17,
        "invoiceNo": invoiceModel.invoiceNo,
        "buyerData": buyerData,
        "receiptLinesTaxInclusive": true,
        "receiptLines": receiptLines,
        "receiptPayments": [
          {
            "moneyTypeCode": "CASH",
            "paymentAmount": receiptTotal,
          }
        ],
        "receiptTotal": receiptTotal,
        "receiptTaxAmount": receiptTaxAmount,
        "receiptPrintForm": "InvoiceA4"
      });

      request.headers.addAll(headers);
      print("createReceipt API Url ---> $url");
      print("Request Body ---> ${request.body}");

      // Send the request
      http.StreamedResponse response = await request.send();

      print("Response Status Code ---> ${response.statusCode}");

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print('Receipt created successfully: $responseBody');

        Get.snackbar(
          'Success',
          'Receipt created successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Failed to create receipt: $responseBody');

        Get.snackbar(
          'Error',
          'Failed to create receipt',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error occurred while creating receipt: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      await updateLoading(false);
    }
  }

  double _calculateTotal(InvoiceModel model) {
    return model.items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.price) ?? 0.0);
    });
  }

  double _calculateTax(InvoiceModel model) {
    return model.items.fold(0.0, (sum, item) {
      final price = double.tryParse(item.price) ?? 0.0;
      final tax = item.taxPercentage is String
          ? double.tryParse(item.taxPercentage) ?? 0
          : item.taxPercentage;
      return sum + (price * (tax / 100));
    });
  }
}
