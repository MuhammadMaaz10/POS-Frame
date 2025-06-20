import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/add_customer_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/add_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/customers_screen/customers_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/items_screen/items_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/settings_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:get/get.dart';

import '../add_invoices_screen/add_invoices_screen.dart';
import 'invoices_screen/invoices_screen.dart';

class HomeScreenMain extends StatefulWidget {
  const HomeScreenMain({super.key}); // Added constructor for consistency

  @override
  _HomeScreenMainState createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreenMain> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        toolbarHeight: 80.h,
        backgroundColor: Color(0xFF00144D),
        titleSpacing: 18.w,
        title: barLogo(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 18.w),
            child: settingsIcon(onTap: () => Get.to(SettingsScreen())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.buttonClr,
              unselectedLabelColor: AppColors.smallTextClr,
              indicatorColor: AppColors.buttonClr,
              labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: AppColors.buttonClr,
                  width: 2.w,
                ),
                insets: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              dividerColor: Colors.transparent,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Invoices'),
                Tab(text: 'Items'),
                Tab(text: 'Customers'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          InvoicesScreen(),
          ItemsScreen(),
          CustomersScreen(),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 56.w,
        height: 56.h,
        child: SpeedDial(
          icon: Icons.add,
          backgroundColor: AppColors.buttonClr,
          foregroundColor: AppColors.secondaryClr,
          overlayOpacity: 0.1,
          children: [
            SpeedDialChild(
              onTap: () => Get.to(() =>  AddInvoicesScreen()),
              shape: const CircleBorder(),
              backgroundColor: AppColors.bgClr,
              foregroundColor: Colors.white,
              labelBackgroundColor: AppColors.bgClr,
              label: "Create Invoice",
              labelStyle: TextStyle(color: Colors.white70,fontSize: 12.sp, fontWeight: FontWeight.w500),
              child: Padding(
                padding: EdgeInsets.only(top: 3.w),
                child: SvgPicture.asset(AppImages.invoiceIcon,height: 18.sp,),
              ),
            ),
            SpeedDialChild(
              onTap: () => Get.to(() =>  AddItemScreen()),
              shape: const CircleBorder(),
              backgroundColor: AppColors.bgClr,
              foregroundColor: Colors.white,
              labelBackgroundColor: AppColors.bgClr,
              label: "Add Item",
              labelStyle: TextStyle(color: Colors.white70,fontSize: 12.sp, fontWeight: FontWeight.w500),
              child: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: SvgPicture.asset(AppImages.itemIcon,height: 18.sp,),
              ),
            ),
            SpeedDialChild(
              onTap: () => Get.to(() =>  AddCustomerScreen()),
              shape: const CircleBorder(),
              backgroundColor: AppColors.bgClr,
              foregroundColor: Colors.white,
              labelBackgroundColor: AppColors.bgClr,
              label: "Add Customer",
              labelStyle: TextStyle(color: Colors.white70,fontSize: 12.sp, fontWeight: FontWeight.w500),
              child: Padding(
                padding: EdgeInsets.only(left: 5.w),
                child: SvgPicture.asset(AppImages.itemIcon,height: 18.sp,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}