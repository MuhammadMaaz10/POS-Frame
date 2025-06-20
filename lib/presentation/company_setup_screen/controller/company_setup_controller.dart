import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
  //
  // void checkEmailAndNavigate(String email) {
  //   final box = Hive.box<UserModel>('users');
  //   final user = box.values.firstWhereOrNull((u) => u.username == email);
  //
  //   if (user == null) {
  //     CustomGetSnackBar.show(
  //       title: "Email Not Found",
  //       message: "No account exists for this email",
  //       backgroundColor: AppColors.buttonClr,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } else {
  //
  //     final resetPassController=Get.put(ResetPasswordController());
  //     resetPassController.email=email;
  //     // Navigate to reset password screen and pass the email
  //     Get.to(ResetPasswordScreen());
  //     // AppRouter.to(resetPassScreen);
  //   }
  // }

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


}