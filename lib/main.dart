import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame_virtual_fiscilation/routes/app_pages.dart'; // Ensure this path is correct
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'local_storage/company_model.dart';
import 'local_storage/configured_fdms_model.dart';
import 'local_storage/customer_model.dart';
import 'local_storage/invoice_customer.dart';
import 'local_storage/invoice_item.dart';
import 'local_storage/invoice_model.dart';
import 'local_storage/item_model.dart';
import 'local_storage/user_model.dart';
import 'local_storage/vat_category_model.dart'; // Ensure this path is correct

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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



  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
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