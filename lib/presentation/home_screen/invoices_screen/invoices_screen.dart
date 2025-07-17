import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/controller/add_invoice_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/edit_invoices_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_button.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';

import '../../../constants/app_color.dart';
import '../../../constants/app_images.dart';
import '../../../widgets/TextField.dart';
import '../../../widgets/custom_list_tile.dart';
import '../controller/home_screen_controller.dart';

class InvoicesScreen extends StatefulWidget {

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
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
                  text: "Fiscal Day Status",
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              GestureDetector(
                onTap: () => homeController.clearQrUrlsFromHive(),
                child: CustomText(
                    text: "-",
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // ElevatedButton(
          //   onPressed: () => homeController.processReceiptsSequentially(),
          //   child: Text("Start Processing"),
          // ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 100.w,vertical: 3.h),
            child: CustomButton(
              text: "FDMS Sync All",
              onPressed: () => homeController.processReceiptsSequentially(),),
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
                  // print("item is ${item.items[0].hsCode}");
                  // Calculate total price for this invoice
                  final invoiceTotal = item.items.fold<double>(
                    0.0,
                        (sum, item) => sum + (double.tryParse(item.price) ?? 0.0),
                  );
                  print("singleInvoiceQrURL ---> ${singleInvoiceQrURL}");

                  // homeController.createReceipt(invoiceModel: homeController.filteredInvoiceList.last, index: 0);
                  return Obx(() {
                    final qrUrl = index < homeController.qrUrlList.length
                        ? homeController.qrUrlList[index]
                        : null;

                    return GestureDetector(
                        onLongPress: () =>
                            invoiceVerificationBottomSheet(
                              title: item.customer.name,
                              invoicID: item.invoiceNo,
                              date: item.invoiceDate,
                              imagePath: item.customer.pic,
                              price: invoiceTotal.toString(),
                              // status: qrUrl || singleInvoiceQrURL != null ? true: false,
                                status: (qrUrl != null || singleInvoiceQrURL != "") ? true : false,
                                qrUrl: qrUrl ?? "",
                              context: context,
                              itemIndex: index
                            ),
                        child: InvoiceCustomListTile(
                          onTap: () {
                            final invoice = item;
                            invoiceController.editInvoiceIDController.text =
                                invoice.invoiceNo.toString();
                            invoiceController.editIndexInvoice = index;
                            invoiceController.editInvoiceNumber.value =
                                invoice.invoiceNo.toString();
                            invoiceController.editSelectedCustomer.value =
                                item.customer;
                            invoiceController.editSelectedItem.value = invoice.items;
                            invoiceController.editDateController.text =
                                item.invoiceDate.toString();
                            invoiceController.editDueDateController.text =
                                item.invoiceDueDate.toString();
                            invoiceController.editNotesController.text =
                                item.notes.toString();
                            invoiceController.editAddressController.text = item.termsAndConditions.toString();
                            invoiceController.editSelectedCurrency.value = item.currency ?? "USD";
                            Get.to(EditInvoicesScreen());
                          },
                          titleText: item.customer.name,
                          invoiceID: item.invoiceNo,
                          isTrailing: true,
                          paid: qrUrl != null ? true: false,
                          date: item.invoiceDate,
                          amount: invoiceTotal,
                          imageUrl: File(item.customer.pic).existsSync()
                              ? FileImage(File(item.customer.pic))
                              : AssetImage(AppImages.demo),
                        )
                    );
                  }
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

   /// select item Quantity
   void invoiceVerificationBottomSheet({
     required BuildContext context,
     required String imagePath,
     required String title,
     required String invoicID,
     required String date,
     required String price,
     required bool status,
     required String qrUrl,
     required int itemIndex,
   }) {
     final homeController = Get.find<HomeScreenController>();

     showModalBottomSheet(
       context: context,
       backgroundColor: AppColors.bgClr,
       shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
       ),
       builder: (context) {
         return Padding(
           padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               // Header row
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   CustomText(
                     text: 'Verify Invoice?',
                     fontSize: 18,
                     fontWeight: FontWeight.w700,
                     color: Colors.white,
                   ),
                   const Spacer(),
                   GestureDetector(
                     onTap: () => Get.back(),
                     child: Container(
                       padding: const EdgeInsets.all(4),
                       decoration: const BoxDecoration(
                         color: Color(0xFF172349),
                         shape: BoxShape.circle,
                       ),
                       child: Icon(
                         Icons.close,
                         size: 18.sp,
                         color: Colors.white70,
                       ),
                     ),
                   ),
                 ],
               ),
               20.ht,

               Padding(
                 padding: EdgeInsets.only(bottom: 10.h),
                 child: InvoiceCustomListTile(
                   titleText: title,
                   invoiceID: invoicID,
                   isTrailing: true,
                   paid: status,
                   date: date,
                   amount: double.tryParse(price),
                   imageUrl: File(imagePath).existsSync()
                       ? FileImage(File(imagePath))
                       : AssetImage(AppImages.demo) ,// Use a valid asset path
                   // onTap: () {},
                 ),
               ),

               // Reactive List of Items
               // Obx(() {
               //   return ListView.builder(
               //     shrinkWrap: true,
               //     itemCount: homeController.itemList.length,
               //     itemBuilder: (context, index) {
               //       final item = homeController.itemList[index];
               //
               //       return GestureDetector(
               //         onTap: () {
               //           // selectedItem.value = item;
               //           // Navigator.pop(context);
               //         },
               //         child: Padding(
               //             padding: EdgeInsets.only(bottom: 10.h),
               //             child: InvoiceCustomListTile(
               //               titleText: title,
               //               invoiceID: invoicID,
               //               isTrailing: true,
               //               paid: status,
               //               date: date,
               //               amount: double.tryParse(price),
               //               imageUrl: File(imagePath).existsSync()
               //                   ? FileImage(File(imagePath))
               //                   : AssetImage(AppImages.demo) ,// Use a valid asset path
               //               // onTap: () {},
               //             ),
               //         ),
               //       );
               //     },
               //   );
               // }),
               30.ht,
               CustomButton(
                 text: "Send To FDMS",
                 onPressed: () {
                   homeController.processSingleReceipt(itemIndex);
                   Navigator.pop(context);
                 }
               ),
               10.ht,
               CustomButton(
                 text: "Verify",
                 onPressed: () => launchQR(qrUrl ?? singleInvoiceQrURL),
               ),
             ],
           ),
         );
       },
     );
   }
   void launchQR(String qrUrl) async {
     final uri = Uri.parse(qrUrl);
     if (await canLaunchUrl(uri)) {
       await launchUrl(uri, mode: LaunchMode.externalApplication);
     } else {
       CustomGetSnackBar.show(
         snackPosition: SnackPosition.BOTTOM,
         duration: Duration(seconds: 2),
         title: 'Error',
         message: 'Could not found QR URL',
         backgroundColor: Colors.red,
       );
     }
   }
}


