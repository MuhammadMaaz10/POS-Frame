import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/settings_screen.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../constants/app_color.dart';
import '../../../constants/app_constants.dart';
import '../../../local_storage/company_model.dart';
import '../../../local_storage/user_model.dart';



class CompanySetupController extends GetxController{

  TextEditingController companyNameController=TextEditingController();
  TextEditingController cityController=TextEditingController();
  TextEditingController provinceController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  TextEditingController contactController=TextEditingController();
  TextEditingController emailController=TextEditingController();
  TextEditingController tinNumberController=TextEditingController();
  TextEditingController vatNumberController=TextEditingController();

   String logoImagePath='';
  Future<String?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Optional: Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = basename(image.path);
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');

      logoImagePath=savedImage.path;
      update();
      return savedImage.path;
    }

    return null;
  }


  Future<void> saveCompany(CompanyModel company) async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<CompanyModel>('companies_$username');
    await box.add(company);
    CustomGetSnackBar.show(
      title: "Success!",
      message: "Company profile created successfully",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );

    var boolBox = await Hive.openBox('settings');
    await boolBox.put('isFromCompany', true); // or false

    await markCompanySetupComplete();


    AppRouter.offAllTo(homeScreen);

  }

  // ✅ ADD THIS METHOD for updating company WITH DEBUG PRINTS
  Future<void> updateCompany(CompanyModel company) async {
    print('updateCompany() called ------');

    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    print("Logged-in username: $username");

    final box = Hive.box<CompanyModel>('companies_$username');
    print("Company box name: companies_$username");
    print("Company box length: ${box.length}");
    print("Company box keys: ${box.keys.toList()}");

    if (box.isEmpty) {
      print("⚠️ Box is EMPTY → update block will NOT run.");
      return;
    }

    print("Box is NOT empty → Proceeding to update.");

    // Update the first company record
    final key = box.keys.first;
    print("Updating company with key: $key");

    await box.put(key, company);
    print("Company updated successfully in Hive.");

    print("Trying to show snackbar...");
    CustomGetSnackBar.show(
      title: "Success!",
      message: "Company profile updated successfully",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );


    Get.off(SettingsScreen());
    print("Get.back() executed.");
  }


  // ✅ ADD THIS METHOD to load existing company data
  Future<CompanyModel?> loadCompany() async {
    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      final box = Hive.box<CompanyModel>('companies_$username');
      
      if (box.isNotEmpty) {
        return box.values.first;
      }
    } catch (e) {
      print('Error loading company: $e');
    }
    return null;
  }


  Future<void> markCompanySetupComplete() async {
    var box = Hive.box<UserModel>('users');
    var settings = await Hive.openBox('settings');
    String? username = settings.get('loggedInUser');

    if (username != null) {
      final user = box.values.firstWhereOrNull((u) => u.username == username);
      if (user != null) {
        user.isCompanySetup = true;
        await user.save(); // Important to persist changes
      }
    }
  }

  @override
  void onClose() {
    companyNameController.dispose();
    cityController.dispose();
    provinceController.dispose();
    addressController.dispose();
    contactController.dispose();
    emailController.dispose();
    tinNumberController.dispose();
    vatNumberController.dispose();
    super.onClose();
  }
}