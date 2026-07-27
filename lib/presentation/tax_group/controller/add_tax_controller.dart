import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/controller/add_item_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/vat_category_model.dart';

class TaxController extends GetxController {
  final nameController = TextEditingController();
  final percentageController = TextEditingController();
  final taxIDController = TextEditingController();
  final isLoading = false.obs;

  List<VatCategoryModel> vatList = [];
  final formKey = GlobalKey<FormState>();
  // final addFormKey = GlobalKey<FormState>();
  final editFormKey = GlobalKey<FormState>();


  @override
  void onInit() async {
    super.onInit();
    vatList = await getVatCategories();
  }

  Future<List<VatCategoryModel>> getVatCategories() async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    update();
    return box.values.toList();
  }

  // Add VAT category
  Future<void> saveVatCategory(VatCategoryModel vatCategory) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    await box.add(vatCategory);
    vatList = box.values.toList();
    update();
  }

  // Delete VAT category
  Future<void> deleteVatCategory(int index) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    await box.deleteAt(index);
    vatList = box.values.toList();
    update();
  }

  // Edit VAT category
  Future<void> editVatCategory(int index, VatCategoryModel updatedCategory) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    await box.putAt(index, updatedCategory);
    vatList = box.values.toList();
    update();
  }

  // Validators
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Tax name is required';
    if (value.length < 2) return 'Tax name must be at least 2 characters';
    return null;
  }

  String? validatePricePercentage(String? value) {
    if (value == null || value.isEmpty) return 'Tax percentage is required';
    return null;
  }

  String? validateTaxID(String? value) {
    if (value == null || value.isEmpty) return 'Tax ID is required';
    return null;
  }

  // ===========================
  // Add Tax Group BottomSheet
  // ===========================
  void addTaxGroupBottomSheet(BuildContext context) {
    Get.back();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          text: 'Add New TAX Group',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF172349),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 18.sp, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    20.ht,
                    CustomTextField(
                      controller: nameController,
                      hintText: "Tax Name",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateName,
                    ),
                    10.ht,
                    CustomTextField(
                      controller: percentageController,
                      hintText: "Tax Percentage",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validatePricePercentage,
                    ),
                    10.ht,
                    CustomTextField(
                      controller: taxIDController,
                      hintText: "Tax ID",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateTaxID,
                    ),
                    30.ht,
                    CustomButton(
                      text: "Add",
                      onPressed: saveItem,
                    ),
                    20.ht,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================
  // Edit Tax Group BottomSheet
  // ===========================
  void editTaxGroupBottomSheet(BuildContext context, int index, VatCategoryModel taxGroup) {
    nameController.text = taxGroup.name;
    percentageController.text = taxGroup.rate;
    taxIDController.text = taxGroup.taxID;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: editFormKey,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(text: "Edit Tax Group", fontSize: 18, color: Colors.white),
                    20.ht,
                    CustomTextField(
                      controller: nameController,
                      hintText: "Tax Name",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateName,
                    ),
                    10.ht,
                    CustomTextField(
                      controller: percentageController,
                      hintText: "Tax Percentage",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validatePricePercentage,
                    ),
                    10.ht,
                    CustomTextField(
                      controller: taxIDController,
                      hintText: "Tax ID",
                      borderColor: Colors.transparent,
                      selectedBorderColor: AppColors.buttonClr,
                      validator: validateTaxID,
                    ),
                    30.ht,
                    CustomButton(
                      text: "Update",
                      onPressed: () {
                        if (editFormKey.currentState!.validate()) {
                          editVatCategory(
                            index,
                            VatCategoryModel(
                              name: nameController.text,
                              rate: percentageController.text,
                              taxID: taxIDController.text,
                            ),
                          );
                          Get.back();
                          CustomGetSnackBar.show(
                            title: 'Success',
                            message: 'Tax group updated successfully!',
                            backgroundColor: AppColors.buttonClr,
                          );
                        }
                      },
                    ),
                    20.ht,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================
  // Delete Confirmation Dialog
  // ===========================
  void confirmDelete(BuildContext context, int index, VatCategoryModel taxGroup) {
    Get.defaultDialog(
      backgroundColor: AppColors.buttonClr.withOpacity(1),
      middleTextStyle: const TextStyle(color: Colors.black),
      titleStyle: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      title: "Delete Tax Group",
      middleText: "Are you sure you want to delete ${taxGroup.name}?",
      textCancel: "Cancel",
      cancelTextColor: Colors.black,
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await deleteVatCategory(index);
        Get.back();
        CustomGetSnackBar.show(
          title: 'Deleted',
          message: '${taxGroup.name} deleted successfully!',
          backgroundColor: AppColors.buttonClr,
        );
      },
    );
  }

  // Save item logic
  void saveItem() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () async {
        isLoading.value = false;
        saveVatCategory(
          VatCategoryModel(
            name: nameController.text,
            rate: percentageController.text,
            taxID: taxIDController.text,
          ),
        );
        AddItemController().refreshVayCategories();
        Get.back();

        CustomGetSnackBar.show(
          title: 'Success',
          message: 'Tax ${nameController.text} Group saved successfully!',
          backgroundColor: AppColors.buttonClr,
        );

        // Clear fields after saving
        nameController.clear();
        percentageController.clear();
        taxIDController.clear();
      });
    }
  }
}








// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:frame_virtual_fiscilation/constants/app_color.dart';
// import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
// import 'package:frame_virtual_fiscilation/presentation/add_item/controller/add_item_controller.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
// import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
//
// import '../../../local_storage/vat_category_model.dart';
//
//
// class TaxController extends GetxController {
//   final nameController = TextEditingController();
//   final percentageController = TextEditingController();
//   final taxIDController = TextEditingController();
//   final isLoading = false.obs;
//   List<VatCategoryModel> vatList = [];
//
//   @override
//   void onInit() async{
//     super.onInit();
//     vatList=await getVatCategories();
//   }
//
//   Future<List<VatCategoryModel>> getVatCategories() async{
//     var settingsBox = await Hive.openBox('settings');
//     var username = settingsBox.get('loggedInUser');
//     final box = Hive.box<VatCategoryModel>('vatCategories_$username');
//     update();
//     return box.values.toList();
//
//   }
//   //add vat category to hive
//   Future<void> saveVatCategory(VatCategoryModel vatCategory) async {
//     var settingsBox = await Hive.openBox('settings');
//     var username = settingsBox.get('loggedInUser');
//     final box = Hive.box<VatCategoryModel>('vatCategories_$username');
//     await box.add(vatCategory);
//     update();
//   }
//
//   // Delete VAT category
//   Future<void> deleteVatCategory(int index) async {
//     var settingsBox = await Hive.openBox('settings');
//     var username = settingsBox.get('loggedInUser');
//     final box = Hive.box<VatCategoryModel>('vatCategories_$username');
//
//     await box.deleteAt(index);
//     vatList = box.values.toList();
//     update();
//   }
//
// // Edit VAT category
//   Future<void> editVatCategory(int index, VatCategoryModel updatedCategory) async {
//     var settingsBox = await Hive.openBox('settings');
//     var username = settingsBox.get('loggedInUser');
//     final box = Hive.box<VatCategoryModel>('vatCategories_$username');
//
//     await box.putAt(index, updatedCategory);
//     vatList = box.values.toList();
//     update();
//   }
//
//
//   String? validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Tax name is required';
//     }
//     if (value.length < 2) {
//       return 'Tax Name must be at least 2 characters';
//     }
//     return null;
//   }
//
//
//   String? validatePricePercentage(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Tax perecentage is required';
//     }
//     return null;
//   }
//
//  String? validateTaxID(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Tax ID is required';
//     }
//     return null;
//   }
//
//
//   void addTaxGroupBottomSheet(BuildContext context) {
//
//     Get.back();
//
//     showModalBottomSheet(
//
//       context: context,
//       backgroundColor: AppColors.bgClr,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true, // Enable full-screen scrollable behavior
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 18.w,
//             right: 18.w,
//             top: 18.h,
//             bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
//           ),
//           child: SingleChildScrollView(
//             child: Form(
//               key: formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomText(
//                         text: 'Add New TAX Group',
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                       GestureDetector(onTap: () => Get.back(),
//                         child: Container(
//                           padding: EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF172349),
//                             shape: BoxShape.circle
//                           ),
//                           child: Icon(
//                             Icons.close,
//                             size: 18.sp,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   20.ht,
//                   CustomTextField(
//                       controller: nameController,
//                       hintText: "Tax Name",
//                       borderColor: Colors.transparent,
//                       selectedBorderColor: AppColors.buttonClr,
//                     validator: validateName,
//
//                   ),
//                   10.ht,
//                   CustomTextField(
//                       controller: percentageController,
//                       hintText: "Tax Percentage",
//                       borderColor: Colors.transparent,
//                       selectedBorderColor: AppColors.buttonClr,
//                     validator: validatePricePercentage,
//                   ),
//                   10.ht,
//                   CustomTextField(
//                       controller: taxIDController,
//                       hintText: "Tax ID",
//                       borderColor: Colors.transparent,
//                       selectedBorderColor: AppColors.buttonClr,
//                     validator: validateTaxID,
//                   ),
//
//
//
//
//                   30.ht,
//                   CustomButton(
//                       text: "Add",
//                       onPressed: () => saveItem(),
//                   ),
//                   20.ht
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   final formKey = GlobalKey<FormState>();
//
//   void saveItem() {
//     if (formKey.currentState!.validate()) {
//       isLoading.value = true;
//       Future.delayed( Duration(seconds: 1), () async {
//         isLoading.value = false;
//         saveVatCategory(VatCategoryModel(
//             name:nameController.text,
//             rate:percentageController.text,
//           taxID: taxIDController.text
//         ));
//         AddItemController().refreshVayCategories();
//
//
//         Get.back();
//
//         CustomGetSnackBar.show(
//           title: 'Success',
//           message:
//           'Tax ${nameController.text} Group saved successfully!',
//           backgroundColor: AppColors.buttonClr,
//           // colorText: AppColors.white,
//         );
//         // Clear fields after saving
//         nameController.clear();
//         percentageController.clear();
//         taxIDController.clear();
//
//       });
//     } else {
//       // Get.snackbar(
//       //   'Error',
//       //   selectedImageBytes.value == null
//       //       ? 'Please select an item image'
//       //       : 'Please fill all fields correctly',
//       //   backgroundColor: Colors.red,
//       //   colorText: AppColors.white,
//       // );
//     }
//   }
//
//
//
//
// }