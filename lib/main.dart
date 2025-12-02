import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart'; // Ensure this path is correct
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'local_storage/company_model.dart';
import 'local_storage/configured_fdms_model.dart';
import 'local_storage/customer_model.dart';
import 'local_storage/invoice_customer.dart';
import 'local_storage/invoice_item.dart';
import 'local_storage/invoice_model.dart';
import 'local_storage/item_model.dart';
import 'local_storage/user_model.dart';
import 'local_storage/vat_category_model.dart';
import 'local_storage/qrUrlsList_model.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestBluetoothPermissions();
  // String? deviceId = await getDeviceId();
  // deviceID = deviceId!;
  // print('Device ID: $deviceID');
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);


  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');
  Hive.registerAdapter(CompanyModelAdapter());

  Hive.registerAdapter(ItemModelAdapter());
  Hive.registerAdapter(VatCategoryModelAdapter());
  Hive.registerAdapter(ConfiguredFDMsAdapter());



  Hive.registerAdapter(CustomerModelAdapter());


  Hive.registerAdapter(InvoiceModelAdapter());
  Hive.registerAdapter(InvoiceCustomerAdapter());
  Hive.registerAdapter(InvoiceItemAdapter());
  Hive.registerAdapter(QrUrlsModelAdapter());



  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      Phoenix(
        child: MyApp(),
      ),);
    // DevicePreview(
    //   enabled: true,
    //   builder: (context) => MyApp(), // Wrap your app
    // ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), // Set your design size (e.g., Figma design size)
      minTextAdapt: true, // Adapt font sizes to screen size
      splitScreenMode: true, // Support split-screen mode
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: "Satoshi",
            textTheme: TextTheme(
              bodyMedium: TextStyle(
                color: Colors.white,
                fontSize: 16.sp, // Use ScreenUtil for responsive font size
              ),
            ),
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          initialRoute: AppRouter.getInitialRoute(),
          getPages: AppRouter.getPages(),
        );
      },
    );
  }
}


Future<void> _requestBluetoothPermissions() async {
  var scanStatus = await Permission.bluetoothScan.status;
  if (scanStatus.isDenied) {
    scanStatus = await Permission.bluetoothScan.request();
  }
  print("📡 Bluetooth Scan permission: $scanStatus");

  var connectStatus = await Permission.bluetoothConnect.status;
  if (connectStatus.isDenied) {
    connectStatus = await Permission.bluetoothConnect.request();
  }
  print("🔌 Bluetooth Connect permission: $connectStatus");

  var locationStatus = await Permission.location.status;
  if (locationStatus.isDenied) {
    locationStatus = await Permission.location.request();
  }
  print("📍 Location permission: $locationStatus");
}