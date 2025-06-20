import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({
    super.key,
    this.text = "Login",
    required this.onPressed,
  });

  String? text;
  Callback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          side: WidgetStatePropertyAll(BorderSide.none),
          backgroundColor: WidgetStatePropertyAll(
            Color(0xFF00E3FC),
          ),
        ),
        child: Text(
          text!,
          style: TextStyle(color: Color(0xFF333333), fontFamily: "Satoshi", fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}