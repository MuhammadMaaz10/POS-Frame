import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';

class ResetPasswordController extends GetxController{

  TextEditingController confirmPassController=TextEditingController();
  TextEditingController passwordController=TextEditingController();

  String email='';

  void resetPassword( String newPassword,
      String confirmPassword) {

    // if (newPassword.isEmpty || confirmPassword.isEmpty) {
    //   Get.snackbar("Missing Fields", "Please enter both fields");
    //   return;
    // }
    //
    // if (newPassword != confirmPassword) {
    //   Get.snackbar("Mismatch", "Passwords do not match");
    //   return;
    // }

    final box = Hive.box<UserModel>('users');
    final userKey = box.keys.firstWhere(
          (key) => box.get(key)!.username == email,
      orElse: () => null,
    );

    if (userKey != null) {
      box.put(userKey, UserModel(username: email, password: newPassword));
      CustomGetSnackBar.show(
        title: "Success",
        message: "Password reset successfully",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      // Get.snackbar("Success", "Password reset successfully");
      AppRouter.offAllTo(loginScreen);
    } else {
      Get.snackbar("Error", "Something went wrong");
    }
  }


}