import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_text.dart';

import '../constants/app_color.dart';
import '../constants/app_images.dart';

class ItemsCustomListTile extends StatelessWidget {
  ItemsCustomListTile({
    this.isTrailing = true,
    this.imageUrl,
    this.subTitleText,
    this.titleText = "Empty",
    this.amount = 00,
    this.leftPadding,
    this.onTap,
    this.tileColor
  });
  double? leftPadding ;
  String? titleText;
  String? subTitleText;
  ImageProvider? imageUrl;
  double? amount;
  bool? isTrailing;
  void Function()? onTap;
  Color? tileColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 57.h,
      contentPadding: EdgeInsets.only(left: leftPadding??0,right: 10.w,bottom: 10.h,top: 10.h),
      isThreeLine: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      tileColor: tileColor ?? Color(0xFF172349),
      textColor: Colors.white,
      title: Text(titleText!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      subtitleTextStyle: TextStyle(fontSize: 12, color: AppColors.smallTextClr),
      subtitle: subTitleText != null ? Row(
        children: [
          Text("$subTitleText", style: TextStyle(color: AppColors.smallTextClr, fontFamily: "Satoshi")),
        ],
      ) : SizedBox(),
      minLeadingWidth: imageUrl == null ? 0 : 40,

      leading: imageUrl != null ? ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 40,
          width: 40,
          child: Image(
            image: imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
      ) : SizedBox(),
      trailing: isTrailing! ? Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          "\$${amount?.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ) : SizedBox(height: 0),

    );
  }
}


class InvoiceCustomListTile extends StatelessWidget {
  String? invoiceID;
  Color? inoiveTypeTextcolor;
  String? invoiceType;
  String? titleText;
  String? date;
  ImageProvider? imageUrl;
  bool? paid;
  double? amount;
  bool? isTrailing;
  void Function()? onTap;

  InvoiceCustomListTile({
    super.key,
    this.invoiceID = "INV-001",
    this.invoiceType = "",
    this.isTrailing = true,
    this.imageUrl ,
    this.date,
    this.titleText = "Ahmed Ali",
    this.amount = 728,
    this.paid = true,
    this.onTap,
    this.inoiveTypeTextcolor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 75.h,
      isThreeLine: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      tileColor: Color(0xFF172349),
      textColor: Colors.white,
      minLeadingWidth: imageUrl == null ? 0 : 40,
      leading: imageUrl != null ? ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: Image(image:imageUrl!,fit: BoxFit.cover,),
        ),
      ) : SizedBox(),
      title: Text(titleText!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
      subtitleTextStyle: TextStyle(fontSize: 12.sp, color: AppColors.smallTextClr,fontWeight: FontWeight.w400,),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomText(text: "Invoice ID: $invoiceID",fontSize: 12,color: Colors.white70,fontWeight: FontWeight.w400,),
          date != null ? CustomText(text: "Date: $date",fontSize: 12,color: Colors.white70,fontWeight: FontWeight.w400,) : SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(text: "Document Type:",fontSize: 12,color: Colors.white70,fontWeight: FontWeight.w400,),
              CustomText(text: " $invoiceType",fontSize: 12,color: inoiveTypeTextcolor ?? AppColors.buttonClr,fontWeight: FontWeight.w500,),
            ],
          ),
        ],
      ),
      trailing: isTrailing!
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomText(
            text: paid! ? "Processed ":"Pending ",
            fontSize: 12,
            color: paid! ? Colors.green : AppColors.redClr,
            fontWeight: FontWeight.w500,),
          CustomText(
            text: "\$${amount?.toStringAsFixed(2)}",
              // fontSize: 14.sp,
              fontWeight: FontWeight.w700,
          ),
        ],
      )
          : SizedBox(height: 0),
    );
  }
}
