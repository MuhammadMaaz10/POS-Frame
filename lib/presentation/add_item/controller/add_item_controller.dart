import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/items_screen/items_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/tax_group/controller/add_tax_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/item_model.dart';
import '../../../local_storage/vat_category_model.dart';
import '../../home_screen/controller/home_screen_controller.dart';

class AddItemController extends GetxController {

  /// edit item controllers
  final editHsCodeController = TextEditingController();
  final editNameController = TextEditingController();
  final editCategoryController = TextEditingController();
  final editDescriptionController = TextEditingController();
  final editPriceController = TextEditingController();
  final editVatCategoryNameController = TextEditingController();
  final editVatCategoryPercentageController = TextEditingController();
  final editVatCategoryTaxIDController = TextEditingController();


  /// add item controllers
  final hsCodeController = TextEditingController();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final vatCategoryNameController = TextEditingController();
  final vatCategoryPercentageController = TextEditingController();
  final vatCategoryTaxIDController = TextEditingController();
  final isLoading = false.obs;
  List<VatCategoryModel> vatList = [];

  final taxController = Get.put(TaxController());
  
  final selectedImageBytes = Rxn<List<int>>();



  @override
  Future<void> onInit() async {
    super.onInit();
    vatList=await getVatCategories();
  }

  String? validateHsCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'HS Code is required';
    }
    if (value.length < 8 || value.length > 8 ) {
      return 'HS Code must be exactly 8 characters';
    }
    // final hsCodeRegex = RegExp(r'^HS-\d{6}$');
    // if (!hsCodeRegex.hasMatch(value)) {
    //   return 'HS Code must be in format HS-XXXXXX (6 digits)';
    // }
    return null;
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

  String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Item category is required';
    }
    if (value.length < 2) {
      return 'Category must be at least 2 characters';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Description must be at least 5 characters if provided';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unit price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Enter a valid positive price';
    }
    return null;
  }

  String? validateVatCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'VAT category is required';
    }
    return null;
  }



  //add items to hive
  Future<void> saveItemHive(ItemModel item) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<ItemModel>('items_$username');
    await box.add(item);
  }

  //get vat category to hive
  Future<List<VatCategoryModel>> getVatCategories() async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');

    final box = Hive.box<VatCategoryModel>('vatCategories_$username');
    update();
    return box.values.toList();
  }
  void refreshVayCategories() async{
    vatList=await getVatCategories();
    update();
  }


  void showTaxGroupBottomSheet(BuildContext context) {


    refreshVayCategories();



    showModalBottomSheet(

      context: context,
      backgroundColor: const Color(0xFF172349),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 14.w),
                child: GestureDetector(
                  onTap: () => taxController.addTaxGroupBottomSheet(context),
                  child: DottedBorder(
                    color: Color(0xFF343A40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white70,
                        ),
                        4.wd,
                        CustomText(
                          text: 'Add New',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vatList.length,
                itemBuilder: (context, index) {
                  final taxGroup = vatList[index];
                  return



                  vatList.isNotEmpty ?


                    GestureDetector(
                    onTap: () {
                      vatCategoryNameController.text = taxGroup.name;
                      vatCategoryPercentageController.text = taxGroup.rate;
                      vatCategoryTaxIDController.text = taxGroup.taxID;
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 14.wd,
                                CustomText(
                                  text: taxGroup.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),

                                CustomText(
                                  text: taxGroup.taxID.toString(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),

                                CustomText(
                                  text: "${taxGroup.rate}%",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                                // 14.wd,
                              ]),
                          Divider(color: Color(0xFF343A40),),
                        ],
                      ),
                    ),
                  ) : Text('No tax found');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditTaxGroupBottomSheet(BuildContext context) {
    refreshVayCategories();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF172349),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h,horizontal: 14.w),
                child: GestureDetector(
                  onTap: () => taxController.addTaxGroupBottomSheet(context),
                  child: DottedBorder(
                    color: Color(0xFF343A40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white70,
                        ),
                        4.wd,
                        CustomText(
                          text: 'Add New',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vatList.length,
                itemBuilder: (context, index) {
                  final taxGroup = vatList[index];
                  return

                  vatList.isNotEmpty ?

                    GestureDetector(
                    onTap: () {
                      editVatCategoryNameController.text = taxGroup.name;
                      editVatCategoryPercentageController.text = taxGroup.rate;
                      editVatCategoryTaxIDController.text = taxGroup.taxID;
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 14.wd,
                                CustomText(
                                  text: taxGroup.name,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                                CustomText(
                                  text: "${taxGroup.rate}%",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                                // 14.wd,
                              ]),
                          Divider(color: Color(0xFF343A40),),
                        ],
                      ),
                    ),
                  ) : Text('No tax found');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final formKey = GlobalKey<FormState>();
  late int editItemIndex;

  void saveItem() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () {
        isLoading.value = false;
        saveItemHive(ItemModel(
          hsCode:hsCodeController.text,
          itemName: nameController.text,
          itemCategory: categoryController.text,
          itemDescription:descriptionController.text,
          unitPrice: double.parse(priceController.text),
          vatCategoryName: vatCategoryNameController.text,
          vatCategoryPercentage: vatCategoryPercentageController.text,
          vatCategoryID: vatCategoryTaxIDController.text,
        ));


        Get.find<HomeScreenController>().loadItems();
        Get.back();
        CustomGetSnackBar.show(
          title: 'Success',
          message:
          'Item ${nameController.text} saved successfully!',
          backgroundColor: AppColors.buttonClr,
          // colorText: AppColors.white,
        );
        // Clear fields after saving
        hsCodeController.clear();
        nameController.clear();
        categoryController.clear();
        descriptionController.clear();
        priceController.clear();
        vatCategoryNameController.clear();
      });
    } else {
    }
  }
  void editItem() async{
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      Future.delayed(const Duration(seconds: 1), () async {
        isLoading.value = false;
       final updatedItem=  ItemModel(
          hsCode:editHsCodeController.text,
          itemName: editNameController.text,
          itemCategory: editCategoryController.text,
          itemDescription:editDescriptionController.text,
          unitPrice: double.parse(editPriceController.text),
          vatCategoryName: editVatCategoryNameController.text,
          vatCategoryPercentage: editVatCategoryPercentageController.text,
          vatCategoryID: editVatCategoryTaxIDController.text,
        );
       print("updated ---> vatCategoryName  = ${editVatCategoryNameController.text}");
        var settingsBox = await Hive.openBox('settings');
        var username = settingsBox.get('loggedInUser');
        final box = Hive.box<ItemModel>('items_$username');
        await box.putAt(editItemIndex,updatedItem);

        Get.find<HomeScreenController>().loadItems();
        Get.back();
        CustomGetSnackBar.show(
          title: 'Success',
          message:
          'Item Edited Successfully!',
          backgroundColor: AppColors.buttonClr,
          // colorText: AppColors.white,
        );
        // Clear fields after saving
        editHsCodeController.clear();
        editNameController.clear();
        editCategoryController.clear();
        editDescriptionController.clear();
        editPriceController.clear();
        editVatCategoryNameController.clear();
        editVatCategoryPercentageController.clear();
        editVatCategoryTaxIDController.clear();
      });
    } else {
    }
  }
  void deleteItem()async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<ItemModel>('items_$username');
    await box.deleteAt(editItemIndex);

    Get.find<HomeScreenController>().loadItems();
    Get.back();
    CustomGetSnackBar.show(
      title: 'Success',
      message:
      'Item Deleted Successfully!',
      backgroundColor: AppColors.buttonClr,
      // colorText: AppColors.white,
    );
  }

  @override
  void onClose() {
    hsCodeController.dispose();
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    vatCategoryNameController.dispose();
    super.onClose();
  }
}