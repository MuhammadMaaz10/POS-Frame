import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/company_model.dart';
import '../../../local_storage/configured_fdms_model.dart';
import '../../../local_storage/customer_model.dart';
import '../../../local_storage/invoice_model.dart';
import '../../../local_storage/item_model.dart';
import '../../../local_storage/user_model.dart';
import '../../../local_storage/vat_category_model.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';

class LoginScreenController extends GetxController{

  TextEditingController emailController=TextEditingController();
  TextEditingController passwordController=TextEditingController();

  Future<void> login(String username, String password) async {
    var box = Hive.box<UserModel>('users');

    final user = box.values.firstWhereOrNull(
          (user) => user.username == username,
    );

    if (user == null) {
      CustomGetSnackBar.show(
        title: "Login Failed",
        message: "Email not found",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
    } else if (user.password != password) {
      CustomGetSnackBar.show(
        title: "Login Failed",
        message: "Password did not match",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      CustomGetSnackBar.show(
        title: "Login Successful",
        message: "Welcome back, ${user.username}",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );


      await openUserBoxes(user.username);

      var box = await Hive.openBox('settings');
      await box.put('isUserLoggedIn', true);
      await box.put('loggedInUser', user.username);
      // Navigate based on company setup
      if (user.isCompanySetup!) {
        AppRouter.offAllTo(homeScreen); // Replace with actual home screen route
      } else {
        AppRouter.offAllTo(companySetupScreen);
      }
    }
  }

  Future<void> openUserBoxes(String username) async {
    await Hive.openBox<CompanyModel>('companies_$username');
    await Hive.openBox<ItemModel>('items_$username');
    await Hive.openBox<VatCategoryModel>('vatCategories_$username');
    await Hive.openBox<CustomerModel>('customers_$username');
    await Hive.openBox<InvoiceModel>('invoices_$username');
    await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');
  }
  // Future<void> login(String username, String password) async {
  //   var box = Hive.box<UserModel>('users');
  //   var authBox = Hive.box('auth');
  //
  //   final user = box.values.firstWhereOrNull((user) => user.username == username);
  //
  //   if (user == null) {
  //     CustomGetSnackBar.show(
  //       title: "Login Failed",
  //       message: "Email not found",
  //       backgroundColor: AppColors.buttonClr,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } else if (user.password != password) {
  //     CustomGetSnackBar.show(
  //       title: "Login Failed",
  //       message: "Password did not match",
  //       backgroundColor: AppColors.buttonClr,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   } else {
  //     CustomGetSnackBar.show(
  //       title: "Login Successful",
  //       message: "Welcome back, ${user.username}",
  //       backgroundColor: AppColors.buttonClr,
  //       snackPosition: SnackPosition.TOP,
  //     );
  //     // Store login state or user info
  //     authBox.put('isLoggedIn', true);
  //     authBox.put('username', user.username);
  //     // Navigate to CreateCompany screen
  //     AppRouter.offAllTo(companySetupScreen);
  //   }
  // }


}