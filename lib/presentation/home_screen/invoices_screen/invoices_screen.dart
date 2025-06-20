import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/controller/add_invoice_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/edit_invoices_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../../constants/app_color.dart';
import '../../../constants/app_images.dart';
import '../../../widgets/TextField.dart';
import '../../../widgets/custom_list_tile.dart';
import '../controller/home_screen_controller.dart';

class InvoicesScreen extends StatelessWidget {

   final  homeController = Get.put(HomeScreenController());
   final invoiceController = Get.put(AddInvoicesController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w,vertical: 20.h),
      child: Column(
        children: [
          CustomTextField(
              controller: homeController.searchInvoiceController,
              hintText: "Search",
              prefixIcon: Icons.search,
              borderColor: Colors.transparent,
              selectedBorderColor: AppColors.buttonClr
          ),
          20.ht,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                  text: "Outstanding Receivables",
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              CustomText(
                  text: "\$ ${homeController.totalInvoiceRate.value}".toString(),
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),

          20.ht,


          Expanded(
            child:


            Obx(() {
              if (homeController.filteredInvoiceList.isEmpty) {
                return Center(child: Text('No Invoices found'));
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final item = homeController.filteredInvoiceList[index];
                  return InvoiceCustomListTile(
                    onTap: () {
                      final invoice = item;
                      invoiceController.editInvoiceIDController.text = invoice.invoiceNo.toString() ?? "";
                      invoiceController.editIndexInvoice=index;
                      invoiceController.editInvoiceNumber.value = invoice.invoiceNo.toString() ?? "";
                       invoiceController.editSelectedCustomer.value = item.customer ;
                      invoiceController.editSelectedItem.value = invoice.items;
                      invoiceController.editDateController.text = item.invoiceDate.toString() ?? "";
                      invoiceController.editDueDateController.text = item.invoiceDueDate.toString() ?? "";
                      invoiceController.editNotesController.text = item.notes.toString() ?? "";
                      invoiceController.editAddressController.text = item.termsAndConditions.toString() ?? "";
                      Get.to(EditInvoicesScreen());
                    },
                    titleText: item.customer.name,
                    invoiceID: item.invoiceNo,
                    isTrailing: true,
                    paid: true,
                    date: item.invoiceDate,
                    amount: double.tryParse(item.items.price),
                    imageUrl: File(item.customer.pic).existsSync()
                        ? FileImage(File(item.customer.pic))
                        : AssetImage(AppImages.demo) ,// Use a valid asset path
                    // onTap: () {},
                  );
                },
                itemCount: homeController.filteredInvoiceList.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
              );
            }),








          ),






        ],
      ),
    );
  }


}


