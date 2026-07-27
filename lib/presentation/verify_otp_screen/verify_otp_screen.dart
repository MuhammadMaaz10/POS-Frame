import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/TextField.dart';
import 'package:frame_virtual_fiscilation/widgets/form_header.dart';
import 'package:frame_virtual_fiscilation/widgets/rounded_button.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        leading: const AppBarBackButton(),
        backgroundColor: AppColors.bgClr,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, size.height * .05),
        child: Column(
          children: [
            const FormHeader(
              isLogoEnabled: false,
              maintext: "Verify OTP",
              subtext:
                  "We’ve sent a 6-digit code to your email. Enter the code below to continue.",
              sublinktext: null,
              subtextColor: AppColors.smallTextClr,
            ),
            const SizedBox(height: 20),
            TextInputField(
              label: "Verification Code",
              icon: null,
              hintText: "",
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Resend email in ",
                  style: TextStyle(color: AppColors.smallTextClr),
                ),
                Text("00:30", style: TextStyle(color: Colors.white)),
              ],
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [RoundedButton(text: "Verify", onPressed: () {})],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
