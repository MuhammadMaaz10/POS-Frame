import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../local_storage/customer_model.dart';
import '../../home_screen/controller/home_screen_controller.dart';

class CustomerController extends GetxController {
  /// edit customer controllers
  final editNameController = TextEditingController();
  final editEmailController = TextEditingController();
  final editPhoneController = TextEditingController();
  final editAddressController = TextEditingController();
  final ediSelectedImage = Rxn<File>();
  // final isLoading = false.obs;
  // final selectedImage = Rxn<File>();


  /// create customer controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final isLoading = false.obs;
  final selectedImage = Rxn<File>();







  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Customer name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // final phoneRegex = RegExp(r'^\+?[\d\s-]{10,12}$');
    // if (!phoneRegex.hasMatch(value)) {
    //   return 'Enter a valid phone number (10-12 digits)';
    // }
    return null;
  }







  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    // if (value.length < 5) {
    //   return 'Address must be at least 5 characters';
    // }
    return null;
  }

  String? validateImage() {
    if (selectedImage.value == null) {
      return 'Customer image is required';
    }
    return null;
  }



  Future<void> showImagePickerDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: CustomText(
                text: 'Select Image Source',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.white),
              title: CustomText(
                text: 'Camera',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.white),
              title: CustomText(
                text: 'Gallery',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
            10.ht,
          ],
        );
      },
    );
  }
  Future<void> showEditImagePickerDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryClr,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: CustomText(
                text: 'Select Image Source',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.white),
              title: CustomText(
                text: 'Camera',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
              onTap: () {
                Navigator.pop(context);
                editPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.white),
              title: CustomText(
                text: 'Gallery',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
              onTap: () {
                Navigator.pop(context);
                editPickImage(ImageSource.gallery);
              },
            ),
            10.ht,
          ],
        );
      },
    );
  }



  Future<void> saveCustomerHive({
    required String name,
    required String phone,
    required String email,
    required String address,
    File? imageFile,
  }) async {
    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      final customerBox = Hive.box<CustomerModel>('customers_$username');
      final customer = CustomerModel(
        name: name,
        phone: phone,
        email: email,
        address: address,
        imagePath: imageFile?.path ?? "",
      );
      await customerBox.add(customer);
    } catch (e) {
      CustomGetSnackBar.show(
        title: 'Error',
        message: 'Failed to save customer: $e',
        backgroundColor: Colors.red,
      );
    }
  }




  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {

      final tempImage = File(pickedFile.path);

      // Get permanent directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');

      selectedImage.value = savedImage;
    }
  }
  Future<void> editPickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {

      final tempImage = File(pickedFile.path);

      // Get permanent directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final savedImage = await tempImage.copy('${appDir.path}/$fileName');

      ediSelectedImage.value = savedImage;
    }
  }

  final formKey = GlobalKey<FormState>();

  void saveCustomer() {
    if (formKey.currentState!.validate() ) {
      isLoading.value = true;
      // Simulate saving customer data
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          isLoading.value = false;
          await saveCustomerHive(
            name: nameController.text,
            phone: phoneController.text,
            email: emailController.text,
            address: addressController.text,
            imageFile: selectedImage.value,
          );

          Get.find<HomeScreenController>().loadCustomer();
          Get.back();

          CustomGetSnackBar.show(
            title: 'Success',
            message: 'Customer ${nameController.text} saved successfully!',
            backgroundColor: AppColors.buttonClr,
          );

          // Clear fields after saving
          nameController.clear();
          emailController.clear();
          phoneController.clear();
          addressController.clear();
          selectedImage.value = null;
        } catch (e) {
          CustomGetSnackBar.show(
            title: 'Error',
            message: 'Failed to save customer',
            backgroundColor: Colors.red,
          );
        }
      });
    } else {
      // Get.snackbar(
      //   'Error',
      //   selectedImage.value == null
      //       ? 'Please select a customer image'
      //       : 'Please fill all fields correctly',
      //   backgroundColor: Colors.red,
      //   colorText: AppColors.white,
      // );
    }
  }
 late int editCustomerIndex;
   void editCustomer() {
    if (formKey.currentState!.validate() ) {
      isLoading.value = true;
      // Simulate saving customer data
      Future.delayed(const Duration(seconds: 2), () async {
        try {
          isLoading.value = false;
          final updatedCustomer=  CustomerModel(
            name: editNameController.text,
            phone: editPhoneController.text,
            email: editEmailController.text,
            address: editAddressController.text,
            imagePath: ediSelectedImage.value?.path,
          );
          var settingsBox = await Hive.openBox('settings');
          var username = settingsBox.get('loggedInUser');
          final customerBox = Hive.box<CustomerModel>('customers_$username');

          await customerBox.putAt(editCustomerIndex,updatedCustomer);


          Get.find<HomeScreenController>().loadCustomer();
          Get.back();

          CustomGetSnackBar.show(
            title: 'Success',
            message: 'Customer Edited Successfully!',
            backgroundColor: AppColors.buttonClr,
          );

          // Clear fields after saving
          editNameController.clear();
          editEmailController.clear();
          editPhoneController.clear();
          editAddressController.clear();
          ediSelectedImage.value = null;
        } catch (e) {
          CustomGetSnackBar.show(
            title: 'Error',
            message: 'Failed to save customer',
            backgroundColor: Colors.red,
          );
        }
      });
    } else {
      // Get.snackbar(
      //   'Error',
      //   selectedImage.value == null
      //       ? 'Please select a customer image'
      //       : 'Please fill all fields correctly',
      //   backgroundColor: Colors.red,
      //   colorText: AppColors.white,
      // );
    }
  }
  void deleteCustomer()async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final customerBox = Hive.box<CustomerModel>('customers_$username');

    await customerBox.deleteAt(editCustomerIndex);
    Get.find<HomeScreenController>().loadCustomer();
    Get.back();
    CustomGetSnackBar.show(
      title: 'Success',
      message:
      'Customer Deleted Successfully!',
      backgroundColor: AppColors.buttonClr,
      // colorText: AppColors.white,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }
}