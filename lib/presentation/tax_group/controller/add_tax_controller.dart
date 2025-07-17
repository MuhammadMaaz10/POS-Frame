import 'package:dotted_border/dotted_border.dart';
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
  Future<List<VatCategoryModel>> getVatCategories() async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    update();
    return box.values.toList();

  }
  //add vat category to hive
  Future<void> saveVatCategory(VatCategoryModel vatCategory) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    await box.add(vatCategory);
    update();
  }

  @override
  void onInit() async{
    super.onInit();
    vatList=await getVatCategories();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }


  String? validatePricePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tax perecentage is required';
    }
    return null;
  }

 String? validateTaxID(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tax ID is required';
    }
    return null;
  }


  void addTaxGroupBottomSheet(BuildContext context) {

    Get.back();

    showModalBottomSheet(

      context: context,
      backgroundColor: AppColors.bgClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Enable full-screen scrollable behavior
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Add New TAX Group',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      GestureDetector(onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF172349),
                            shape: BoxShape.circle
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
                      onPressed: () => saveItem(),
                  ),
                  20.ht
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  final formKey = GlobalKey<FormState>();

  void saveItem() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      Future.delayed( Duration(seconds: 1), () async {
        isLoading.value = false;
        saveVatCategory(VatCategoryModel(
            name:nameController.text,
            rate:percentageController.text,
          taxID: taxIDController.text
        ));
        AddItemController().refreshVayCategories();


        Get.back();

        CustomGetSnackBar.show(
          title: 'Success',
          message:
          'Tax ${nameController.text} Group saved successfully!',
          backgroundColor: AppColors.buttonClr,
          // colorText: AppColors.white,
        );
        // Clear fields after saving
        nameController.clear();
        percentageController.clear();
        taxIDController.clear();

      });
    } else {
      // Get.snackbar(
      //   'Error',
      //   selectedImageBytes.value == null
      //       ? 'Please select an item image'
      //       : 'Please fill all fields correctly',
      //   backgroundColor: Colors.red,
      //   colorText: AppColors.white,
      // );
    }
  }

  //
  // @override
  // void onClose() {
  //   nameController.dispose();
  //   percentageController.dispose();
  //   super.onClose();
  // }

}