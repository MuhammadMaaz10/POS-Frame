import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_images.dart';
import 'package:frame_virtual_fiscilation/presentation/add_customer/add_customer_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/add_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/customers_screen/customers_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/items_screen/items_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/controller/settings_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/settings_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/store_invoices_screen.dart';
import 'package:frame_virtual_fiscilation/widgets/app_logo.dart';
import 'package:get/get.dart';

import '../add_invoices_screen/add_invoices_screen.dart';
import 'invoices_screen/invoices_screen.dart';

/// PreferredSizeWidget that updates when [useStoreInvoicesMode] changes,
/// so [AppBar.bottom] can react without wrapping the whole Scaffold in Obx.
class _StoreInvoicesAwareBottomBar extends StatefulWidget
    implements PreferredSizeWidget {
  const _StoreInvoicesAwareBottomBar({
    required this.settingsController,
    required this.tabController,
    required this.onTabTap,
    required this.barHeight,
  });
  final SettingsController settingsController;
  final TabController tabController;
  final VoidCallback onTabTap;
  final double barHeight;

  @override
  Size get preferredSize => Size.fromHeight(
      settingsController.useStoreInvoicesMode.value ? 0 : barHeight);

  @override
  State<_StoreInvoicesAwareBottomBar> createState() =>
      _StoreInvoicesAwareBottomBarState();
}

class _StoreInvoicesAwareBottomBarState
    extends State<_StoreInvoicesAwareBottomBar> {
  @override
  void initState() {
    super.initState();
    ever(widget.settingsController.useStoreInvoicesMode, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.settingsController.useStoreInvoicesMode.value) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: TabBar(
        onTap: (value) => widget.onTabTap(),
        controller: widget.tabController,
        labelColor: AppColors.buttonClr,
        unselectedLabelColor: AppColors.smallTextClr,
        indicatorColor: AppColors.buttonClr,
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.buttonClr, width: 2.w),
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
    );
  }
}

class HomeScreenMain extends StatefulWidget {
  const HomeScreenMain({super.key}); // Added constructor for consistency

  @override
  _HomeScreenMainState createState() => _HomeScreenMainState();
}

class _HomeScreenMainState extends State<HomeScreenMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.put(HomeScreenController());
  final controller2 = Get.put(SettingsController());
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    ever(controller2.useStoreInvoicesMode, (_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller2.checkFDMSConfig(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use small Obx widgets only where toggle state is needed, so tab content
    // (InvoicesScreen etc.) updating observables does not rebuild the whole home.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.bgClr,
      appBar: AppBar(
        toolbarHeight: controller2.useStoreInvoicesMode.value ? 52.h : 80.h,
        backgroundColor: Color(0xFF00144D),
        titleSpacing: 18.w,
        title: barLogo(),
        actions: [
          Obx(() => Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Switch(
                  value: controller2.useStoreInvoicesMode.value,
                  onChanged: (value) =>
                      controller2.setStoreInvoicesMode(value),
                  activeTrackColor: AppColors.buttonClr.withOpacity(0.5),
                  activeThumbColor: AppColors.buttonClr,
                  inactiveTrackColor: AppColors.secondaryClr,
                  inactiveThumbColor: AppColors.smallTextClr,
                ),
              )),
          Obx(() {
            final useStoreInvoices = controller2.useStoreInvoicesMode.value;
            if (!useStoreInvoices && _tabController.index == 0) {
              return Padding(
                padding: EdgeInsets.only(right: 5.w),
                child: syncIcon(
                  onTap: () => controller.processReceiptsSequentially(),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller2.useStoreInvoicesMode.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(right: 18.w),
              child: settingsIcon(onTap: () => Get.to(SettingsScreen())),
            );
          }),
        ],
        bottom: _StoreInvoicesAwareBottomBar(
          settingsController: controller2,
          tabController: _tabController,
          onTabTap: () => setState(() {}),
          barHeight: 48.h,
        ),
      ),
      body: Obx(() {
        if (controller2.useStoreInvoicesMode.value) {
          // No top SafeArea here: body already sits below AppBar; applying top
          // padding again left a visible gap above the store tab bar.
          return SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: StoreInvoicesScreen(embedded: true),
          );
        }
        return SafeArea(
          child: TabBarView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              Builder(builder: (_) => InvoicesScreen()),
              Builder(builder: (_) => ItemsScreen()),
              Builder(builder: (_) => CustomersScreen()),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller2.useStoreInvoicesMode.value) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: 56.w,
          height: 56.h,
          child: SpeedDial(
            icon: Icons.add,
            backgroundColor: AppColors.buttonClr,
            foregroundColor: AppColors.secondaryClr,
            overlayOpacity: 0.1,
            children: [
              SpeedDialChild(
                onTap: () => Get.to(() => AddInvoicesScreen()),
                shape: const CircleBorder(),
                backgroundColor: AppColors.bgClr,
                foregroundColor: Colors.white,
                labelBackgroundColor: AppColors.bgClr,
                label: "Create Invoice",
                labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500),
                child: Padding(
                  padding: EdgeInsets.only(top: 3.w),
                  child: SvgPicture.asset(
                    AppImages.invoiceIcon,
                    height: 18.sp,
                  ),
                ),
              ),
              SpeedDialChild(
                onTap: () => Get.to(() => AddItemScreen()),
                shape: const CircleBorder(),
                backgroundColor: AppColors.bgClr,
                foregroundColor: Colors.white,
                labelBackgroundColor: AppColors.bgClr,
                label: "Add Item",
                labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500),
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: SvgPicture.asset(
                    AppImages.itemIcon,
                    height: 18.sp,
                  ),
                ),
              ),
              SpeedDialChild(
                onTap: () => Get.to(() => AddCustomerScreen()),
                shape: const CircleBorder(),
                backgroundColor: AppColors.bgClr,
                foregroundColor: Colors.white,
                labelBackgroundColor: AppColors.bgClr,
                label: "Add Customer",
                labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500),
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: SvgPicture.asset(
                    AppImages.itemIcon,
                    height: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
