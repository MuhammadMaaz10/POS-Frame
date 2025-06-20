import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/controller/add_customer_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/edit_customer_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../../constants/app_color.dart';
import '../../../constants/app_images.dart';
import '../../../widgets/custom_list_tile.dart';
import '../controller/home_screen_controller.dart';

class CustomersScreen extends StatelessWidget {
  final  homeController = Get.put(HomeScreenController());
  final customerController = Get.put(CustomerController());


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        children: [
          CustomTextField(
              controller: homeController.searchCustomerController,
              hintText: "Search",
              prefixIcon: Icons.search,
              borderColor: Colors.transparent,
              selectedBorderColor: AppColors.buttonClr,
          ),
          // TextInputField(
          //   label: "Search",
          //   icon: Icons.search,
          //   suffixicon: Icons.sort,
          //   hintText: "",
          // ),
          20.ht,
          Expanded(
            child:


            Obx(() {
              if (homeController.filteredCustomerList.isEmpty) {
                return Center(child: Text('No Customer found'));
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final item = homeController.filteredCustomerList[index];
                  return ItemsCustomListTile(
                    onTap:() {

                      customerController.editCustomerIndex = index;
                      customerController.editNameController.text = item.name.toString() ?? "";
                      customerController.editEmailController.text = item.email.toString() ?? "";
                      customerController.editAddressController.text = item.address.toString() ?? "";
                      customerController.editPhoneController.text = item.phone.toString() ?? "";
                       customerController.ediSelectedImage.value = (File(item.imagePath!));
                      Get.to(EditCustomerScreen());
                    },
                    titleText: item.name,
                    subTitleText: item.email,
                    imageUrl:item.imagePath != null &&File(item.imagePath!).existsSync()
                        ? FileImage(File(item.imagePath!))
                        : AssetImage(AppImages.demo) ,
                    isTrailing: false,
                    leftPadding: 10.w,
                  );
                },
                itemCount: homeController.filteredCustomerList.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
              );
            }),








          ),
        ],
      ),
    );
  }


}


