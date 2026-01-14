
import 'dart:convert';
import 'dart:io';
import 'package:frame_virtual_fiscilation/presentation/fiscal_device_management/controller/fiscal_day_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/settings/controller/settings_controller.dart';

import '../../../constants/urls.dart';
import '../../../local_storage/configured_fdms_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/local_storage/customer_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/invoice_model.dart';
import 'package:frame_virtual_fiscilation/presentation/add_invoices_screen/controller/add_invoice_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/invoice_pdf_generation_screen/invoice_pdf_generation_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/invoice_pdf_generation_screen/model/invoice_pdf_preview_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../local_storage/item_model.dart';import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../local_storage/qrUrlsList_model.dart';
class HomeScreenController extends GetxController {

  // final settingsController = Get.put(SettingsController());


  final searchItemController = TextEditingController();
  var totalInvoiceRate = 0.obs;
  var itemList = <ItemModel>[].obs;
  var filteredItemList = <ItemModel>[].obs;

  final searchCustomerController = TextEditingController();
  var customerList = <CustomerModel>[].obs;
  var filteredCustomerList = <CustomerModel>[].obs;

  final searchInvoiceController = TextEditingController();
  var invoiceList = <InvoiceModel>[].obs;
  var filteredInvoiceList = <InvoiceModel>[].obs;
  final qrUrlList = <String?>[].obs; // Keeping as requested
  final isLoading = false.obs;
  static const String qrUrlKey = 'qrUrls';

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? username = await getLoggedInUsername();
      if (username != null) {
        await loadQrUrlsFromHive(username);
        print('load QrUrlsFromHive--------------- user found.');
      } else {
        print('No logged in user found.');
      }
    });
    loadItems();
    loadCustomer();
    loadInvoice();
    initializeQrUrlList();
    searchItemController.addListener(() {
      filterItems(searchItemController.text);
    });
    searchCustomerController.addListener(() {
      filterCustomers(searchCustomerController.text);
    });
    searchInvoiceController.addListener(() {
      filterInvoices(searchInvoiceController.text);
    });
    loadAndPrintConfigs();
  }

  Future<void> loadAndPrintConfigs() async {
    print('-----------loadAndPrintConfigs--------------');
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');

    final box = await Hive.openBox<ConfiguredFDMs>('configured_fdms_$username');

    print('Total configs in box: ${box.length}');

    // if (box.length > 1) {
    //   print("⚠️ Found ${box.length} old entries in box. Clearing...");
    //   await box.clear();
    //   print("✅ Box cleared. Now length: ${box.length}");
    // } else {
    //   print("ℹ️ Box already clean. Current length: ${box.length}");
    // }

    if (box.isEmpty) {
      print('⚠️ No configs found for user: $username');
      return;
    }

    int index = 0;
    for (var config in box.values) {
      print('Config #$index');
      print('Client ID: ${config.clientID}');
      fiscalDeviceID = config.deviceID;
      fiscalApiKey = config.apiKey;

      print('Device ID: ${fiscalDeviceID}');
      if(fiscalDeviceID != ""){
        print("--------------- fiscalDeviceID is ${fiscalDeviceID} --------");
        // ✅ Use Get.find or Get.put to ensure controller is accessible
        final fiscalController = Get.put(FiscalDeviceManagementController());
        await fiscalController.getFiscalDayData();
      }else{
        print("--------------- fiscalDeviceID is empty --------");
      }
      print('API Key: ${config.apiKey}');
      print('-------------------------');
      index++;
    }
  }


  void loadItems() async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<ItemModel>('items_$username');
    itemList.value = box.values.toList();
    filteredItemList.value = itemList;
  }

  void loadCustomer() async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<CustomerModel>('customers_$username');
    customerList.value = box.values.toList();
    filteredCustomerList.value = customerList;
  }

  void loadInvoice() async {
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<InvoiceModel>('invoices_$username');
    invoiceList.value = box.values.toList();
    filteredInvoiceList.value = invoiceList;
    double total = 0;
    for (var invoice in invoiceList) {
      for (var item in invoice.items) {
        total += (double.tryParse(item.price) ?? 0);
      }
    }
    totalInvoiceRate.value = total.toInt();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItemList.value = itemList;
    } else {
      filteredItemList.value = itemList
          .where((item) => item.itemName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomerList.value = customerList;
    } else {
      filteredCustomerList.value = customerList
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void filterInvoices(String query) {
    if (query.isEmpty) {
      filteredInvoiceList.value = invoiceList;
    } else {
      filteredInvoiceList.value = invoiceList
          .where((item) => item.customer.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void initializeQrUrlList() {
    qrUrlList.assignAll(List<String?>.filled(filteredInvoiceList.length, null));
  }

  Future<void> saveQrUrls(List<String?> qrUrls) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('qrUrlList', jsonEncode(qrUrls));
      print('QR URLs saved to SharedPreferences successfully');
    } catch (e) {
      print('Error saving QR URLs to SharedPreferences: $e');
    }
  }

  Future<void> loadQrUrls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('qrUrlList');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        qrUrlList.assignAll(jsonList.map((e) => e as String?));
        print('QR URLs loaded in Splash: $qrUrlList');
      } else {
        print('No QR URLs found in SharedPreferences.');
      }
    } catch (e) {
      print('Error loading QR URLs: $e');
    }
  }

  Future<void> clearQrUrls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('qrUrlList');
      qrUrlList.clear();
      print('QR URLs cleared from SharedPreferences and memory.');
    } catch (e) {
      print('Error clearing QR URLs: $e');
    }
  }

  bool loading = false;

  Future<void> updateLoading(bool value) async {
    loading = value;
    // notifyListeners();
  }

  Future<void> processReceiptsSequentially() async {
    print("🔄 processReceiptsSequentially() called ------");
    if (!await hasInternetConnection()) {
      print("❌ No internet connection found.");
      Get.snackbar(
        "No Internet",
        "Please check your internet connection",
        backgroundColor: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    print("⏳ isLoading set to TRUE");

    // Reset qrUrlList for fresh processing (keeping as requested)
    qrUrlList.assignAll(List.filled(filteredInvoiceList.length, null));
    print("🔁 qrUrlList reset with ${filteredInvoiceList.length} empty items");

    update();

    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      print("👤 Retrieved username: $username");
      final invoiceBox = Hive.box<InvoiceModel>('invoices_$username');
      print("📂 Opened Hive box: invoices_$username");

      for (int index = 0; index < filteredInvoiceList.length; index++) {
        final invoice = filteredInvoiceList[index];
        // Skip invoices with non-empty qrUrl
        if (invoice.qrUrl != null && (invoice.qrUrl as String).isNotEmpty) {
          print("⏭ Skipping invoice ${invoice.invoiceNo} at index $index (already has qrUrl: ${invoice.qrUrl})");
          qrUrlList[index] = invoice.qrUrl; // Sync qrUrlList with model
          print("🔄 Synced qrUrlList[$index] with invoice.qrUrl: ${qrUrlList[index]}");
          continue;
        }
        print("📦 Processing invoice ${invoice.invoiceNo} at index ${index + 1} of ${filteredInvoiceList.length}");
        await createReceipt(invoiceModel: invoice, index: index);
        // Save updated invoice to Hive
        await invoiceBox.put(invoice.key, invoice);
        print("✅ Saved updated invoice ${invoice.invoiceNo} to Hive with qrUrl: ${invoice.qrUrl}");
      }

      print("💾 Saving QR URLs to SharedPreferences...");
      await saveQrUrls(qrUrlList);
      print("✅ Saved qrUrlList to SharedPreferences: $qrUrlList");

      // Reuse username from above
      if (username != null) {
        print("👤 Saving QR URLs to Hive for user: $username");
        await saveQrUrlsToHive(username, qrUrlList);
        print('📝 Saved QR URLs in Hive for user $username: $qrUrlList');
      } else {
        print('⚠️ No logged-in user found.');
      }

      print('🎉 All QR URLs saved successfully: $qrUrlList');
    } catch (e) {
      print("🔥 ERROR while processing: $e");
      Get.snackbar(
        'Error',
        'Processing failed: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr, // Fixed to buttonClr for consistency
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      print("✅ isLoading set to FALSE (Process completed)");
    }
  }

  Future<void> processSingleReceipt(int index) async {
    if (index < 0 || index >= filteredInvoiceList.length) {
      print("❌ Invalid index: $index");
      Get.snackbar(
        'Error',
        'Invalid index: $index',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (!await hasInternetConnection()) {
      print("❌ No internet connection found.");
      Get.snackbar(
        'No Internet',
        'Please check your internet connection',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    print("⏳ isLoading set to TRUE for single receipt at index $index");
    try {
      final invoice = filteredInvoiceList[index];
      print("📦 Processing invoice ${invoice.invoiceNo} at index $index");
      // Skip if already processed
      if (invoice.qrUrl != null && (invoice.qrUrl as String).isNotEmpty) {
        print("⏭ Invoice ${invoice.invoiceNo} already processed with qrUrl: ${invoice.qrUrl}");
        qrUrlList[index] = invoice.qrUrl; // Sync qrUrlList
        print("🔄 Synced qrUrlList[$index] with invoice.qrUrl: ${qrUrlList[index]}");
        Get.snackbar(
          'Info',
          'Invoice ${invoice.invoiceNo} already processed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.buttonClr,
          duration: Duration(seconds: 3),
        );
        return;
      }
      if (index >= qrUrlList.length) {
        qrUrlList.addAll(List<String?>.filled(index - qrUrlList.length + 1, null));
        print("📏 Extended qrUrlList to length ${qrUrlList.length} for index $index");
      }
      await createReceipt(invoiceModel: invoice, index: index);
      // Save updated invoice to Hive
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      print("👤 Retrieved username: $username");
      final invoiceBox = Hive.box<InvoiceModel>('invoices_$username');
      print("📂 Opened Hive box: invoices_$username");
      await invoiceBox.put(invoice.key, invoice);
      print("✅ Saved updated invoice ${invoice.invoiceNo} to Hive with qrUrl: ${invoice.qrUrl}");

      // Get.snackbar(
      //   'Success',
      //   'Invoice processed for item ${index + 1}',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: AppColors.buttonClr,
      //   duration: Duration(seconds: 3),
      // );

      if (username != null) {
        print("👤 Saving QR URLs to Hive for user: $username");
        await saveQrUrlsToHive(username, qrUrlList);
        print('📝 Saved QR URLs in Hive for single item -- user: $username, urls: $qrUrlList');
      } else {
        print('⚠️ No logged-in user found.');
      }
    } catch (e) {
      print('🔥 Error processing receipt at index $index: $e');
      Get.snackbar(
        'Error',
        'Failed to process receipt at index $index: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      print("✅ isLoading set to FALSE for single receipt at index $index");
      await saveQrUrls(qrUrlList);
      print("💾 Saved qrUrlList to SharedPreferences: $qrUrlList");
    }
  }

  Future<void> processSingleInvoicePreview(int index, String url) async {
    if (index < 0 || index >= filteredInvoiceList.length) {
      Get.snackbar(
        'Error',
        'Invalid index: $index',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (!await hasInternetConnection()) {
      Get.snackbar(
        'No Internet',
        'Please check your internet connection',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    try {
      // Use invoice's qrUrl if available, otherwise fall back to provided url
      final invoice = filteredInvoiceList[index];
      final qrUrl = (invoice.qrUrl != null && (invoice.qrUrl as String).isNotEmpty) ? invoice.qrUrl : url;
      await invoicePreview(invoiceModel: invoice, index: index, qrUrl: qrUrl as String);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process Invoice preview at index $index: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> invoicePreview({required InvoiceModel invoiceModel, required int index, required String qrUrl})
  async {
    print('Starting receipt creation process...');
    List<ReceiptLines> receiptLines = [];
    for (int i = 0; i < invoiceModel.items.length; i++) {
      final item = invoiceModel.items[i];
      receiptLines.add(ReceiptLines(
        receiptLineHSCode: item.hsCode ?? "99001000",
        receiptLineType: "Sale",
        receiptLineNo: i + 1,
        receiptLineName: item.name,
        receiptLineQuantity: item.quantity is String
            ? (double.tryParse(item.quantity) ?? 1.0).toInt()
            : item.quantity,
        receiptLineTotal: (double.tryParse(item.price) ?? 0.0).toDouble(),
        taxPercent: item.taxPercentage is String
            ? double.tryParse(item.taxPercentage) ?? 0
            : item.taxPercentage,
        taxID: item.taxID?.toString() ?? "2",
      ));
    }

    final buyerData = BuyerData(
      buyerRegisterName: invoiceModel.customer.name,
      buyerTIN: invoiceModel.customer.tinNumber ?? "0000000000",
      buyerVAT: invoiceModel.customer.vatNumber ?? "",
      buyerAddress: BuyerAddress(
        houseNumber: invoiceModel.customer.houseNumber,
        street: invoiceModel.customer.street,
        city: invoiceModel.customer.city,
        province: invoiceModel.customer.provience,
      ),
    );

    double receiptTotal = _calculateTotal(invoiceModel);
    double receiptTaxAmount = _calculateTax(invoiceModel);

    invoicePdfPreviewModel previewModel = invoicePdfPreviewModel(
      receiptType: invoiceModel.invoiceType,
      // receiptType: "FiscalInvoice",
      receiptCurrency: invoiceModel.currency,
      receiptGlobalNo: 1,
      invoiceNo: invoiceModel.invoiceNo,
      buyerData: buyerData,
      receiptLinesTaxInclusive: true,
      receiptLines: receiptLines,
      receiptPayments: [
        ReceiptPayments(
          moneyTypeCode: "CASH",
          paymentAmount: receiptTotal.toInt(),
        )
      ],
      receiptTotal: receiptTotal.toDouble(),
      receiptTaxAmount: receiptTaxAmount,
      receiptPrintForm: "Receipt48",
    );

    print("Preview Model Data index $index  --- : $previewModel");
    print("buyerTIN: Data index $index  --- : ${previewModel.buyerData!.buyerTIN}");
    Get.to(InvoiceScreenPdfView(previewModel: previewModel, qrUrl: qrUrl));
  }

  final controller = Get.put(AddInvoicesController());
  Future<void> createReceipt({
    required InvoiceModel invoiceModel,
    required int index,
  })
  async {
    print("api called -----");
    await updateLoading(true);
    try {
      print('Starting receipt creation process...');
      var headers = {
        'Content-Type': 'application/json',
        "apiKey": "$fiscalDeviceID",
      };
      String url = 'http://frame-server.af-south-1.elasticbeanstalk.com/api/v1/client/receipts/25811';
      var request = http.Request('POST', Uri.parse(createReceiptUrl));

      // Build receipt lines
      List<Map<String, dynamic>> receiptLines = [];
      for (int i = 0; i < invoiceModel.items.length; i++) {
        final item = invoiceModel.items[i];
        receiptLines.add({
          "receiptLineHSCode": item.hsCode ?? "99001000",
          "receiptLineType": "Sale",
          "receiptLineNo": i + 1,
          "receiptLineName": item.name,
          "receiptLineQuantity": item.quantity is String
              ? double.tryParse(item.quantity) ?? 1.0
              : item.quantity.toDouble(),
          "receiptLineTotal": double.tryParse(item.price)!.toStringAsFixed(2) ?? 0.0,
          "taxPercent": item.taxPercentage is String
              ? double.tryParse(item.taxPercentage) ?? 0
              : item.taxPercentage,
          "taxID": item.taxID ?? 2,
        });
      }

      // Build buyer data
      final buyerData = {
        "buyerRegisterName": invoiceModel.customer.name,
        "buyerTIN": invoiceModel.customer.tinNumber ?? "0000000000",
        "buyerVAT": invoiceModel.customer.vatNumber ?? "",
        "buyerAddress": {
          "houseNumber": invoiceModel.customer.houseNumber,
          "street": invoiceModel.customer.street,
          "city": invoiceModel.customer.city,
          "province": invoiceModel.customer.provience,
        }
      };

      // Totals
      double receiptTotal = _calculateTotal(invoiceModel);
      double receiptTaxAmount = _calculateTax(invoiceModel);

      // Base request body (common for all types)
      final Map<String, dynamic> requestBody = {
        "receiptType": invoiceModel.invoiceType,
        "receiptCurrency": invoiceModel.currency,
        "receiptGlobalNo": 1,
        "invoiceNo": invoiceModel.invoiceNo,
        "buyerData": buyerData,
        "receiptLinesTaxInclusive": true,
        "receiptLines": receiptLines,
        "receiptPayments": [
          {
            "moneyTypeCode": "CASH",
            "paymentAmount": receiptTotal.toStringAsFixed(2),
          }
        ],
        "receiptTotal": receiptTotal.toStringAsFixed(2),
        "receiptTaxAmount": receiptTaxAmount.toStringAsFixed(2),
        "receiptPrintForm": "Receipt48",
      };

      // Add extra params only if NOT FiscalInvoice
      if (invoiceModel.invoiceType != "FiscalInvoice") {
        requestBody.addAll({
          "receiptNotes": controller.editNotesController.text,
          // "creditDebitNote": {
          //   "originalInvoice": invoiceModel.invoiceNo
          // },

          "creditDebitNote": {
            "deviceID": 25811,
            "receiptGlobalNo": 4,
            "fiscalDayNo": AppConstant.fiscalDayNumber,
          },
        });
      }

      // Encode request body
      request.body = jsonEncode(requestBody);

      // Add headers
      request.headers.addAll(headers);

      // Debug logs
      print("createReceipt API Url ---> $url");
      print("Request Body ---> ${request.body}");

      // Send request
      http.StreamedResponse response = await request.send();
      print("Response Status Code ---> ${response.statusCode}");


      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        final body = jsonDecode(responseBody);
        print('Receipt statusCode : ${response.statusCode}');
        print("Response body ---> ${body}");

        String qrUrl = body['qrUrl'] ?? "";
        // Update InvoiceModel with qrUrl
        invoiceModel.qrUrl = qrUrl;
        // Update qrUrlList (keeping as requested)
        if (index >= qrUrlList.length) {
          qrUrlList.addAll(List<String?>.filled(index - qrUrlList.length + 1, null));
        }
        qrUrlList[index] = qrUrl;
        qrUrlList.refresh();
        print('Receipt created successfully for index: $index, qrUrl: $qrUrl');
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Receipt statusCode : ${response.statusCode}');
        print('Failed to create receipt: $responseBody');
        Get.snackbar(
          'Error',
          'Failed to create receipt',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.buttonClr,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error occurred while creating receipt: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
    } finally {
      await updateLoading(false);
    }
  }

  double _calculateTotal(InvoiceModel model) {
    return model.items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.price) ?? 0.0);
    });
  }

  double _calculateTax(InvoiceModel model) {
    double totalTax = model.items.fold(0.0, (sum, item) {
      final total = double.tryParse(item.price) ?? 0.0;
      final taxPercent = item.taxPercentage is String
          ? double.tryParse(item.taxPercentage) ?? 0.0
          : (item.taxPercentage as num).toDouble();
      if (taxPercent == 0) return sum;
      return sum + (total * taxPercent / (100 + taxPercent));
    });
    return (totalTax * 100).round() / 100;
  }

  Future<String?> getLoggedInUsername() async {
    var settingsBox = await Hive.openBox('settings');
    return settingsBox.get('loggedInUser');
  }

  Future<void> saveQrUrlsToHive(String username, List<String?> qrUrls) async {
    var box = await Hive.openBox<QrUrlsModel>('qrUrls');
    final existing = box.values.firstWhere(
          (element) => element.username == username,
      orElse: () => QrUrlsModel(username: username, qrUrls: []),
    );
    existing.qrUrls = qrUrls;
    await box.put(username, existing);
    print('QR URLs saved to Hive for user $username');
  }

  Future<void> loadQrUrlsFromHive(String username) async {
    var box = await Hive.openBox<QrUrlsModel>('qrUrls');
    final qrModel = box.get(username);
    if (qrModel != null) {
      qrUrlList.assignAll(qrModel.qrUrls.map((e) => e?.toString()));
      print('Loaded QR URLs from Hive for $username: ${qrUrlList}');
    } else {
      qrUrlList.clear();
      print('No QR URLs found in Hive for $username');
    }
  }

  Future<void> clearQrUrlsFromHive() async {
    var box = await Hive.openBox<QrUrlsModel>('qrUrls');
    String? username = await getLoggedInUsername();
    if (username != null) {
      await box.delete(username);
      qrUrlList.clear();
      print('Cleared QR URLs in Hive for $username');
    } else {
      print('Not Cleared logged in user not found.');
    }
  }

}
