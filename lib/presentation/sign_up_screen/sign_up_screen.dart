import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/login_screen/login_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/sign_up_screen/controller/sign_up_screen_controlelr.dart';
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

// class SignUpScreen extends StatelessWidget {
// final signUpController=Get.put(SignUpScreenController());
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
//           padding: EdgeInsets.symmetric(horizontal: 18, vertical: size.height * .05),
//           child: Column(
//             children: [
//               Expanded(
//                 flex: 12,
//                 child: Column(
//                   children: [
//                     FormHeader(
//                       maintext: "Create Account",
//                       subtext: "Already have an account? ",
//                       sublinktext: "Sign In",
//                     ),
//                     TextInputField(
//                       controller: signUpController.emailController,
//                       color: Colors.white,
//                     ),
//                     SizedBox(height: 10),
//                     TextInputField(
//                       label: "Password",
//                       controller: signUpController.passwordController,
//                       suffixicon: Icons.remove_red_eye_outlined,
//                       icon: Icons.lock_outlined,
//                     ),
//                     SizedBox(height: 10),
//                     TextInputField(
//                       label: "Confirm Password",
//                       controller: signUpController.confirmPasswordController,
//                       suffixicon: Icons.remove_red_eye_outlined,
//                       icon: Icons.lock_outlined,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 10,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     RoundedButton(text: "Register", onPressed: () {
//
//                       final email = signUpController.emailController.text.trim();
//
//                       final emailRegex = RegExp(
//                         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//                       );
//
//
//
//                       if (email.isEmpty) {
//                         Get.snackbar("Missing Email", "Please enter your email");
//                       } else if (!emailRegex.hasMatch(email)) {
//                         Get.snackbar("Invalid Email", "Please enter a valid email address");
//                       }
//                       else if (signUpController.passwordController.text.isEmpty) {
//                         Get.snackbar("Missing Password", "Please enter your password");
//                       } else if (signUpController.confirmPasswordController.text.isEmpty) {
//                         Get.snackbar("Confirm Password", "Please confirm your password");
//                       } else if (signUpController.passwordController.text !=
//                           signUpController.confirmPasswordController.text) {
//                         Get.snackbar("Mismatch", "Passwords do not match");
//                       } else {
//                         // All conditions are valid, proceed with sign up
//                         signUpController.signUp(
//                           signUpController.emailController.text,
//                           signUpController.passwordController.text,
//                         );
//                       }
//
//
//
//
//                     } ),
//                     SizedBox(
//                       height: 30,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               color: Color.fromRGBO(52, 58, 64, 1),
//                               thickness: 1,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12.0,
//                             ),
//                             child: Text('OR'),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               color: Color.fromRGBO(52, 58, 64, 1),
//                               thickness: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       spacing: 20,
//                       children: [
//                         SmallRoundedButton(size: size),
//                         SmallRoundedButton(
//                           size: size,
//                           imgUrl: AppImages.appleLogo,
//                           text: "Apple",
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpScreenController signUpController = Get.put(SignUpScreenController());

  final _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      signUpController.signUp(
        signUpController.emailController.text,
        signUpController.passwordController.text,
      );
    }
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                39.ht,
                SvgAppLogo(),
                40.ht,
                CustomText(
                  text: "Create Account",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                10.ht,
                Row(
                  children: [
                    CustomText(
                      text: "Already have an account? ",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(LoginScreen());
                      },
                      child: CustomText(
                        text: "Sign In",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.buttonClr,
                      ),
                    ),
                  ],
                ),
                16.ht,
                CustomTextField(
                  controller: signUpController.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: validateEmail,
                ),
                16.ht,
                CustomTextField(
                  controller: signUpController.passwordController,
                  hintText: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  maxLines: 1,
                  obscureText: isPasswordVisible,
                  onSuffixTap: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: validatePassword,
                ),
                16.ht,
                CustomTextField(
                  controller: signUpController.confirmPasswordController,
                  hintText: 'Confirm Password',
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  isPassword: true,
                  maxLines: 1,
                  obscureText: isConfirmPasswordVisible,
                  onSuffixTap: () => setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible),
                  borderColor: Colors.transparent,
                  selectedBorderColor: AppColors.buttonClr,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm Password is required';
                    if (value != signUpController.passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                189.ht,
                CustomButton(
                  text: 'Register',
                  onPressed: _signUp,
                  isLoading: false,
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
                      onPressed: () {},
                    ),
                    20.wd,
                    CustomSocialButton(
                      icon: AppImages.appleIcon,
                      text: 'Apple',
                      onPressed:() {},
                    ),
                  ],
                ),
                20.ht

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class SignUpScreenController extends GetxController {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   var isPasswordVisible = false.obs;
//   var isConfirmPasswordVisible = false.obs;
//
//   void togglePasswordVisibility() => isPasswordVisible.value = !isPasswordVisible.value;
//   void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
//
//   Future<void> signUp(String email, String password) async {
//     // Implement sign-up logic here
//   }
// }