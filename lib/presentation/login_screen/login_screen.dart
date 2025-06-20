import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/forgot_password_screen/forgot_password_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/sign_up_screen/sign_up_screen.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart';
import 'package:frame_virtual_fiscilation/routes/app_routes.dart';
import 'package:frame_virtual_fiscilation/widgets/TextField.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_social_icon.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:frame_virtual_fiscilation/widgets/validation.dart';
import 'package:get/get.dart';

import '../../widgets/form_header.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/small_rounded_button.dart';
import 'controller/login_screen_controller.dart';

// class LoginScreen extends StatelessWidget {
//   final loginController=Get.put(LoginScreenController());
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//
//     return SafeArea(
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: AppColors.bgClr,
//         body: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 40.h),
//           child: Column(
//             children: [
//               FormHeader(
//                   onSublinktextClick:(){
//                     AppRouter.offTo(signUpScreen);
//                   }
//               ),
//               TextInputField(
//                 color: Colors.white,
//                 controller: loginController.emailController,
//
//               ),
//               SizedBox(height: 10),
//               TextInputField(
//                 label: "Password",
//                 suffixicon: Icons.remove_red_eye_outlined,
//                 icon: Icons.lock_outlined,
//                 color: Colors.white,
//
//                 controller: loginController.passwordController,
//               ),
//               SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: InkWell(
//                   onTap: (){
//                     AppRouter.to(forgotPassScreen);
//                   },
//                   child: Text(
//                     "Forgot Password?",
//                     textAlign: TextAlign.end,
//                     style: TextStyle(
//                       color: Color.fromRGBO(255, 255, 255, 0.7),
//                       fontFamily: "Satoshi",
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//               RoundedButton(onPressed: () {
//                 final email = loginController.emailController.text.trim();
//
//                 final emailRegex = RegExp(
//                   r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//                 );
//
//
//
//                 if (email.isEmpty) {
//                   Get.snackbar("Missing Email", "Please enter your email");
//                 } else if (!emailRegex.hasMatch(email)) {
//                   Get.snackbar("Invalid Email", "Please enter a valid email address");
//                 }
//                 else if (loginController.passwordController.text.isEmpty) {
//                   Get.snackbar("Missing Password", "Please enter your password");
//                 }  else {
//                   // All conditions are valid, proceed with sign up
//                   loginController.login(
//                     loginController.emailController.text,
//                     loginController.passwordController.text,
//                   );
//                 }
//
//
//               }),
//               SizedBox(
//                 height: 30,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         color: Color.fromRGBO(52, 58, 64, 1),
//                         thickness: 1,
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12.0,
//                       ),
//                       child: Text('OR'),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         color: Color.fromRGBO(52, 58, 64, 1),
//                         thickness: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 spacing: 20,
//                 children: [
//                   SmallRoundedButton(size: size),
//                   SmallRoundedButton(
//                     size: size,
//                     imgUrl: AppImages.appleLogo,
//                     text: "Apple",
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





















//////////
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController=Get.put(LoginScreenController());
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;




  void _login() {
    if (_formKey.currentState!.validate()) {
      loginController.login(
        loginController.emailController.text,
        loginController.passwordController.text,
      );
      // setState(() => _isLoading = true);
      // // Simulate login process
      // Future.delayed(const Duration(seconds: 2), () {
      //   setState(() => _isLoading = false);
      //   // Navigate or handle login success
      // });
    }
  }

  void _googleLogin() {
    // Handle Google login
  }

  void _appleLogin() {
    // Handle Apple login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                39.ht,
                SvgAppLogo(),
                40.ht,
                CustomText(
                    text: "Sign In",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                10.ht,
                Row(
                  children: [
                    CustomText(
                      text: "Don’t have an account? ",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(SignUpScreen());
                      },
                      child: CustomText(
                        text: "Sign Up",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.buttonClr,
                      ),
                    ),
                  ],
                ),
                16.ht,
                CustomTextField(
                  controller: loginController.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: validateEmail,
                ),
                16.ht,
                CustomTextField(
                  controller: loginController.passwordController,
                  hintText: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  maxLines: 1,
                  obscureText: !_isPasswordVisible,
                  onSuffixTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: validatePassword,
                ),
                16.ht,
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(ForgotPasswordScreen());
                    },
                    child: CustomText(
                      text: "Forgot Password?",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
                225.ht,
                CustomButton(
                  text: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                10.ht,
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF343A40))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: CustomText(
                        text: "OR",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF343A40))),
                  ],
                ),
                10.ht,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSocialButton(
                      icon: AppImages.googleIcon,
                      text: 'Google',
                      onPressed: _googleLogin,
                    ),
                    20.wd,
                    CustomSocialButton(
                      icon: AppImages.appleIcon,
                      text: 'Apple',
                      onPressed: _appleLogin,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







