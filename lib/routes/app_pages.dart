import 'package:frame_virtual_fiscilation/presentation/company_setup_screen/company_setup_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/forgot_password_screen/forgot_password_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/reset_password_screen/reset_password_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/sign_up_screen/sign_up_screen.dart';
import 'package:get/get.dart';

import '../presentation/add_invoices_screen/add_invoices_screen.dart';
import '../presentation/home_screen/home_screen_main.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/unknown_page.dart';
import '../presentation/verify_otp_screen/verify_otp_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static getUnknownRoute() {
    return GetPage(
      name: noPageFound,
      page: () => const UnknownRoutePage(),
      transition: Transition.zoom,
    );
  }

  static getInitialRoute() {
    return splashScreen;
  }

  static getPages() {
    return [
      GetPage(
        name: splashScreen,
        page: () => SplashScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: loginScreen,
        page: () => LoginScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: signUpScreen,
        page: () => SignUpScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: verifyOtpScreen,
        page: () => VerifyOtpScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: forgotPassScreen,
        page: () => ForgotPasswordScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: resetPassScreen,
        page: () => ResetPasswordScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: companySetupScreen,
        page: () => CompanySetupScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: homeScreen,
        page: () => HomeScreenMain(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
      GetPage(
        name: addInvoicesScreen,
        page: () => AddInvoicesScreen(),
        // transition: Transition.cupertino,
        // transitionDuration: 100.milliseconds,
      ),
    ];
  }

  static to(String route, {Map<String, dynamic>? arguments}) =>
      Get.toNamed(route, arguments: arguments);

  static offAllTo(String route, {Map<String, dynamic>? arguments}) =>
      Get.offAllNamed(route, arguments: arguments);

  static offTo(String route, {Map<String, dynamic>? arguments}) =>
      Get.offNamed(route, arguments: arguments);

  static back() => Get.back();
}
