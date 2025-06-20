import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/user_model.dart';

class SignUpScreenController extends GetxController{

 TextEditingController emailController=TextEditingController();
 TextEditingController passwordController=TextEditingController();
 TextEditingController confirmPasswordController=TextEditingController();

 bool isPasswordVisible = false;
 bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() => isPasswordVisible = !isPasswordVisible;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible = !isConfirmPasswordVisible;


 Future<void> signUp(String username, String password) async {
   var box = Hive.box<UserModel>('users');

   // Check if username already exists
   bool exists = box.values.any((user) => user.username == username);
   if (exists) {
     CustomGetSnackBar.show(
       title: "Signup Failed",
       message: "Username already exists",
       backgroundColor: AppColors.buttonClr,
       snackPosition: SnackPosition.TOP,
     );
     return;
   }

   box.add(UserModel(username: username, password: password));
   CustomGetSnackBar.show(
     title: "Register Successful",
     message: "You can now log in",
     backgroundColor: AppColors.buttonClr,
     snackPosition: SnackPosition.TOP,
   );

   AppRouter.offAllTo(loginScreen);
 }


}