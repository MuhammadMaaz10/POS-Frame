import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_day_report/controller/fiscal_day_report_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:get/get.dart';

class FiscalDayReportScreen extends StatelessWidget {
  FiscalDayReportScreen({Key? key}) : super(key: key);

  final controller = Get.put(FiscalDayReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: CustomText(
          text: "Fiscal Day Report",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Enter Fiscal Day Number",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
              ),
              10.ht,
              Row(
                children: [
                  InkWell(
                    onTap: controller.decrementDay,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.buttonClr,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Icon(Icons.remove, color: Colors.black),
                      ),
                    ),
                  ),
                  15.wd,
                  Expanded(
                    child: TextFormField(
                      controller: controller.fiscalDayNoController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF172349),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                  15.wd,
                  InkWell(
                    onTap: controller.incrementDay,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.buttonClr,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              40.ht,
              Obx(() => CustomButton(
                isLoading: controller.isLoading.value,
                text: "Generate Report",
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.fetchReport();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
