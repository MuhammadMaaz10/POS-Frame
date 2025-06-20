import 'package:flutter/material.dart';
import 'package:get/get.dart';


class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Unknown route',
          style: Get.textTheme.headlineLarge,
        ),
      ),
    );
  }
}