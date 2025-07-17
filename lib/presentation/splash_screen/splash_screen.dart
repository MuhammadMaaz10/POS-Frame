import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/company_setup_screen/company_setup_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/login_screen/controller/login_screen_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/login_screen/login_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      await moveToNext();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/logos/logo.svg",
              width: 309.w,
              height: 200.h,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> moveToNext() async {
    var box = await Hive.openBox('settings');
    bool isLoggedIn = box.get('isUserLoggedIn', defaultValue: false);
    bool isFromCompany = box.get('isFromCompany', defaultValue: false);
    String? username = box.get('loggedInUser');

    if (isLoggedIn && username != null) {
      final loginController = Get.put(LoginScreenController());
      await loginController.openUserBoxes(username); // Open user-specific Hive boxes
      // Initialize HomeScreenController and load qrUrlList
      // final homeController = Get.put(HomeScreenController());
      // await homeController.loadQrUrls(); // Load QR URLs from SharedPreferences
    }

    if (!isLoggedIn) {
      AppRouter.offAllTo(loginScreen);
    } else if (!isFromCompany) {
      AppRouter.offAllTo(companySetupScreen);
    } else {
      AppRouter.offAllTo(homeScreen);
    }
  }
}