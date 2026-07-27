
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/add_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/controller/add_item_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/tax_group/controller/add_tax_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/app_bar_back_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../local_storage/vat_category_model.dart';
class TaxGroupScreen extends StatefulWidget {
  const TaxGroupScreen({super.key});

  @override
  _TaxGroupScreenState createState() => _TaxGroupScreenState();
}

class _TaxGroupScreenState extends State<TaxGroupScreen> {
  final controller = Get.put(TaxController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        backgroundColor: AppColors.bgClr,
        title: const CustomText(
          text: "Tax Group Management",
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        leading: const AppBarBackButton(color: AppColors.white),
      ),
      body: SafeArea(
        child: GetBuilder(
          init: TaxController(),
          builder: (_){
            return  SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 0.h),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    10.ht,
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.vatList.length,
                      itemBuilder: (context, index) {
                        final taxGroup = controller.vatList[index];
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172349),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tax info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: "Tax Name:  ${taxGroup.name}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  CustomText(
                                    text: "Tax Percentage:  ${taxGroup.rate}%",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                  CustomText(
                                    text: "Tax ID:  ${taxGroup.taxID}",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),

                              // Action buttons
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit, color: AppColors.buttonClr),
                                    onPressed: () => controller.editTaxGroupBottomSheet(
                                      context,      // pass context for bottom sheet
                                      index,        // index of the current item
                                      taxGroup,     // the current VatCategoryModel from your list
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.redClr),
                                    onPressed: () => controller.confirmDelete(context, index, taxGroup),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )


                    // ListView.builder(
                    //   physics: NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   itemCount: controller.vatList.length,
                    //   itemBuilder: (context, index) {
                    //     print("Tax group ---> ${controller.vatList.length}");
                    //     final taxGroup = controller.vatList[index];
                    //     return
                    //
                    //       controller.vatList.isNotEmpty ?
                    //
                    //
                    //       customContainar(
                    //           taxName: taxGroup.name,
                    //           percentage: "${taxGroup.rate}%"
                    //
                    //       ) : Center(child: Text('No tax found'));
                    //   },)

                  ],
                ),
              ),
            );
          },


        ),
      ),
      floatingActionButton: SizedBox(
        width: 56.w,
        height: 56.h,
        child: SpeedDial(
          onPress: () {
            controller.addTaxGroupBottomSheet(context);
            // Get.to(AddItemScreen());
          },
          icon: Icons.add,
          backgroundColor: AppColors.buttonClr,
          foregroundColor: AppColors.secondaryClr,
          overlayOpacity: 0.1,
        ),
      ),
    );
  }
}

customContainar({required String taxName, required String percentage,}){
  return Container(
    padding: EdgeInsets.symmetric(horizontal:10.w, vertical: 10.h),
    margin: EdgeInsets.only(bottom:10.h),
    decoration: BoxDecoration(
      color: const Color(0xFF172349),
      borderRadius: BorderRadius.circular(10.r)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: "$taxName",
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        CustomText(
          text: "$percentage",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ],
    ),
  );
}