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
import 'package:intl/intl.dart';

import '../../../local_storage/invoice_customer.dart';
import '../../../local_storage/invoice_item.dart';
import '../../../local_storage/invoice_model.dart';
import '../../home_screen/controller/home_screen_controller.dart';

class AddInvoicesController extends GetxController {

  /// edit invoice controllers
  final editInvoiceNumber = ''.obs;
  final editSelectedCustomer = Rxn<InvoiceCustomer>();
  final editSelectedItem = Rxn<InvoiceItem>();
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

  void generateInvoiceNumber() {
    final random = Random().nextInt(9999);
    invoiceNumber.value = 'INV-${random.toString().padLeft(4, '0')}';
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
                         editSelectedCustomer.value=InvoiceCustomer(name: customer.name,
                             pic: customer.imagePath ?? AppImages.demo, email: customer.email);
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

  void showItemBottomSheet(BuildContext context) {
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
                    text: 'Select Item',
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

              // Reactive List of Items
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
                    shrinkWrap: true,
                    itemCount: homeController.itemList.length,
                    itemBuilder: (context, index) {
                      final item = homeController.itemList[index];

                      return GestureDetector(
                        onTap: () {
                          // showItemQuantityBottomSheet(context);
                          // selectedItem.value = item;
                          // Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ItemsCustomListTile(
                            onTap: () {
                              selectedItem.value = item;
                              Navigator.pop(context);
                             }
                            ,
                            imageUrl: null, // or `item.imagePath` if you have one
                            titleText: item.itemName,
                            subTitleText: item.itemCategory,
                            isTrailing: true,
                            amount: item.unitPrice,
                            leftPadding: 10.w,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void showEditItemBottomSheet(BuildContext context) {
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
                    text: 'Select Item',
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

              // Reactive List of Items
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
                    shrinkWrap: true,
                    itemCount: homeController.itemList.length,
                    itemBuilder: (context, index) {
                      final item = homeController.itemList[index];

                      return GestureDetector(
                        onTap: () {
                          // showItemQuantityBottomSheet(context);
                          // selectedItem.value = item;
                          // Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ItemsCustomListTile(
                            onTap: () {
                              editSelectedItem.value = InvoiceItem(
                                name: item.itemName,
                                category: item.itemCategory,
                                price: item.unitPrice.toString(),
                                // Add any other required InvoiceItem fields if necessary
                              );
                              Navigator.pop(context);
                             }
                            ,
                            imageUrl: null, // or `item.imagePath` if you have one
                            titleText: item.itemName,
                            subTitleText: item.itemCategory,
                            isTrailing: true,
                            amount: item.unitPrice,
                            leftPadding: 10.w,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
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
                  // SizedBox(
                  //   width: 82.w,
                  //   child: CustomSmallButton(
                  //     text: "Add New",
                  //     onPressed: () {
                  //       Get.to(AddItemScreen());
                  //     },
                  //   ),
                  // ),
                  // 10.wd,
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
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: homeController.itemList.length,
                    itemBuilder: (context, index) {
                      final item = homeController.itemList[index];

                      return GestureDetector(
                        onTap: () {
                          // selectedItem.value = item;
                          // Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ListTile(
                            onTap: () {},
                            minTileHeight: 57.h,
                            contentPadding: EdgeInsets.only(left: 0,right: 10.w,bottom: 10.h,top: 10.h),
                            isThreeLine: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            tileColor: Color(0xFF172349),
                            textColor: Colors.white,
                            title: Text(item.itemName, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                            subtitleTextStyle: TextStyle(fontSize: 12, color: AppColors.smallTextClr),
                            subtitle: Row(
                              children: [
                                Text(item.itemCategory, style: TextStyle(color: AppColors.smallTextClr, fontFamily: "Satoshi")),
                              ],
                            ),
                            minLeadingWidth:  0 ,

                            leading: SizedBox(),
                            trailing: Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                "\$${item.unitPrice}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                          )


                          // ItemsCustomListTile(
                          //   imageUrl: null, // or `item.imagePath` if you have one
                          //   titleText: item.itemName,
                          //   subTitleText: item.itemCategory,
                          //   isTrailing: true,
                          //   amount: item.unitPrice,
                          //   leftPadding: 10.w,
                          // ),
                        ),
                      );
                    },
                  ),
                );
              }),
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
    required String itemName,
    required String itemCategory,
    required String itemPrice,
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
    );

    final items=InvoiceItem(
       name: itemName,
       price: itemPrice,
       category: itemCategory
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
    );

    // Save to Hive box
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<InvoiceModel>('invoices_$username');
    await box.add(invoice);
  }



  Future<void> selectDate(BuildContext context,
      {required bool isInvoiceDate}) async {
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
    if (selectedItem.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select an item",
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


    createAndSaveInvoice(
      invoiceNo: invoiceNumber.value,
      customerName: selectedCustomer.value!.name,
      customerPic: selectedCustomer.value!.imagePath!,
      customerEmail: selectedCustomer.value!.email,
      itemName: selectedItem.value!.itemName,
      itemCategory: selectedItem.value!.itemCategory,
      itemPrice: selectedItem.value!.unitPrice.toString(),
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

    if (editSelectedItem.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select an item",
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
    );

    final updatedItem = InvoiceItem(
      name: editSelectedItem.value!.name,
      price: editSelectedItem.value!.price.toString(),
      category: editSelectedItem.value!.category,
    );

    final updatedInvoice = InvoiceModel(
      invoiceNo: editInvoiceNumber.value,
      customer: updatedCustomer,
      items: updatedItem,
      invoiceDate: editDateController.text,
      invoiceDueDate: editDueDateController.text,
      notes: editNotesController.text,
      termsAndConditions: editAddressController.text,
    );

    // Update in Hive
    await invoiceBox.putAt(editIndexInvoice, updatedInvoice);

    // Reload and notify
    Get.find<HomeScreenController>().loadInvoice();
    Get.back();

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

    // Build updated data



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


class Customer {
  final String name;
  final String email;
  final String image;

  Customer({required this.name, required this.email, required this.image});
}

class Item {
  final String name;
  final String category;
  final double price;

  Item({required this.name, required this.category, required this.price});
}