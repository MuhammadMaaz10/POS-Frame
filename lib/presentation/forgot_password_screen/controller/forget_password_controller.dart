import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/reset_password_screen/reset_password_screen.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';
import '../../reset_password_screen/controller/reset_password_controller.dart';

class ForgetPasswordController extends GetxController{

  TextEditingController emailController=TextEditingController();

  void checkEmailAndNavigate(String email) {
    final box = Hive.box<UserModel>('users');
    final user = box.values.firstWhereOrNull((u) => u.username == email);

    if (user == null) {
      CustomGetSnackBar.show(
        title: "Email Not Found",
        message: "No account exists for this email",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
    } else {

      final resetPassController=Get.put(ResetPasswordController());
      resetPassController.email=email;
      // Navigate to reset password screen and pass the email
      Get.to(ResetPasswordScreen());
      // AppRouter.to(resetPassScreen);
    }
  }


}