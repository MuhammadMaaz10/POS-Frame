import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_color.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/local_storage/customer_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/invoice_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../local_storage/item_model.dart';import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../local_storage/qrUrlsList_model.dart';

class HomeScreenController extends GetxController {
  final searchItemController = TextEditingController();
  var totalInvoiceRate=0.obs;
  var itemList = <ItemModel>[].obs;
  var filteredItemList = <ItemModel>[].obs;

  final searchCustomerController = TextEditingController();
  var customerList = <CustomerModel>[].obs;
  var filteredCustomerList = <CustomerModel>[].obs;

  final  searchInvoiceController = TextEditingController();
  var invoiceList = <InvoiceModel>[].obs;
  var filteredInvoiceList = <InvoiceModel>[].obs;
  final qrUrlList = <String?>[].obs; // List to store QR URLs, initialized with nulls
  final isLoading = false.obs;
  static const String qrUrlKey = 'qrUrls';
  @override
  void onInit() {
    super.onInit();

    // _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
    //   final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    //
    //   if (result == ConnectivityResult.none) {
    //     Get.snackbar("Disconnected", "No Internet Connection", backgroundColor: Colors.red);
    //   } else {
    //     Get.snackbar("Connected Again", "", backgroundColor: Colors.green);
    //     print("Internet connection restored");
    //   }
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? username = await getLoggedInUsername();
      if (username != null) {
        await loadQrUrlsFromHive(username);
        print('load QrUrlsFromHive--------------- user found.');
      }else {
        print('No logged in user found.');
      }
    });
    loadItems();
    loadCustomer();
    loadInvoice();
    initializeQrUrlList(); // Initialize qrUrlList after loading invoices
    searchItemController.addListener(() {
      filterItems(searchItemController.text);
    });

    searchCustomerController.addListener(() {
      filterCustomers(searchCustomerController.text);
    });

    searchInvoiceController.addListener(() {
      filterInvoices(searchInvoiceController.text);
      initializeQrUrlList(); // Re-initialize qrUrlList when invoices are filtered
    });
  }


  void loadItems() async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<ItemModel>('items_$username');
    itemList.value = box.values.toList();
    filteredItemList.value = itemList;
  }
  void loadCustomer() async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<CustomerModel>('customers_$username');
    customerList.value = box.values.toList();
    filteredCustomerList.value = customerList;
  }

  void loadInvoice() async{
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final box = Hive.box<InvoiceModel>('invoices_$username');
    invoiceList.value = box.values.toList();
    filteredInvoiceList.value = invoiceList;
    double total = 0;

    for (var invoice in invoiceList) {
      for (var item in invoice.items) {
        total += (double.tryParse(item.price) ?? 0) ;
      }
    }


    totalInvoiceRate.value = total.toInt();
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItemList.value = itemList;
    } else {
      filteredItemList.value = itemList
          .where((item) =>
          item.itemName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
  void filterCustomers(String query) {
    if (query.isEmpty) {
      filteredCustomerList.value = customerList;
    } else {
      filteredCustomerList.value = customerList
          .where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
  void filterInvoices(String query) {
    if (query.isEmpty) {
      filteredInvoiceList.value = invoiceList;
    } else {
      filteredInvoiceList.value = invoiceList
          .where((item) =>
          item.customer.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Initialize qrUrlList based on filteredInvoiceList length
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
      await prefs.remove('qrUrlList'); // Removes the stored data
      qrUrlList.clear(); // Clears the in-memory list
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

  // Method to processed multiple item Sequentially
  Future<void> processReceiptsSequentially() async {
    print("proccess called ------");

    if (!await hasInternetConnection()) {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection",
        backgroundColor: Colors.red,
      );
      return;
    }
    isLoading.value = true;
    qrUrlList.assignAll(List.filled(filteredInvoiceList.length, null)); // Reset QR URLs
    update();
    for (int index = 0; index < filteredInvoiceList.length; index++) {
      try {
        await createReceipt(invoiceModel: filteredInvoiceList[index], index: index);
      } catch (e) {
        // Stop processing on error
        Get.snackbar(
          'Error',
          'Stopped at index $index: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.buttonClr,
          duration: Duration(seconds: 3),
        );
        break; // Stop further API calls on error
      }
    }
    isLoading.value = false;

    /// ✅ Save the complete QR list after processing all receipts

    await saveQrUrls(qrUrlList);
    String? username = await getLoggedInUsername();
    if (username != null) {
      await saveQrUrlsToHive(username, qrUrlList);
      print('qrUrl data for multiple item in Hive -- user --> $username urls -> $qrUrlList');
    }else {
      print('No logged in user found.');
    }


    print('All QR URLs saved after processing: $qrUrlList');
  }

  /// processed Single item
  Future<void> processSingleReceipt(int index) async {
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
      // Ensure qrUrlList has enough slots
      if (index >= qrUrlList.length) {
        qrUrlList.addAll(List<String?>.filled(index - qrUrlList.length + 1, null));
      }
      await createReceipt(invoiceModel: filteredInvoiceList[index], index: index);
      Get.snackbar(
        'Success',
        'Invoice processed for item ${index+1}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process receipt at index $index: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.buttonClr,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      /// ✅ Save the QR url after processing receipt
      // await saveQrUrls(qrUrlList);

      String? username = await getLoggedInUsername();
      if (username != null) {
        await saveQrUrlsToHive(username, qrUrlList);
        print('qrUrl data for single item in Hive -- user --> $username urls -> $qrUrlList');
      }else {
        print('No logged in user found.');
      }
    }
  }


  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Optional: check actual internet access by pinging Google
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createReceipt({required InvoiceModel invoiceModel, required int index}) async {
    print("api called -----");
    await updateLoading(true);

    try {
      print('Starting receipt creation process...');

      var headers = {
        'Content-Type': 'application/json',
        'apiKey': 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7'
      };

      String url =
          'http://frame-server.af-south-1.elasticbeanstalk.com/api/v1/client/receipts/25811';
      var request = http.Request(
          'POST', Uri.parse(url)
      );

      // Build receipt lines from invoice items
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
          "receiptLineTotal": double.tryParse(item.price) ?? 0.0,
          "taxPercent": item.taxPercentage is String
              ? double.tryParse(item.taxPercentage) ?? 0
              : item.taxPercentage,
          "taxID": item.taxID ?? 2,
        });

      }



      // Extract customer info
      final buyerData = {
        "buyerRegisterName": invoiceModel.customer.name,
        "buyerTIN": invoiceModel.customer.tinNumber ?? "0000000000",
        "buyerAddress": {
          "houseNumber": invoiceModel.customer.houseNumber,
          "street": invoiceModel.customer.street,
          "city": invoiceModel.customer.city,
          "province": invoiceModel.customer.provience,
        }
      };

      // Calculate totals
      double receiptTotal = _calculateTotal(invoiceModel);
      double receiptTaxAmount = _calculateTax(invoiceModel);

      print("invoiceModel.currency ---> ${invoiceModel.currency}");
      // Final body
      request.body = jsonEncode({
        "receiptType": "FiscalInvoice",
        "receiptCurrency": invoiceModel.currency,
        "receiptGlobalNo": 1,
        "invoiceNo": invoiceModel.invoiceNo,
        "buyerData": buyerData,
        "receiptLinesTaxInclusive": true,
        "receiptLines": receiptLines,
        "receiptPayments": [
          {
            "moneyTypeCode": "CASH",
            "paymentAmount": receiptTotal,
          }
        ],
        "receiptTotal": receiptTotal,
        "receiptTaxAmount": receiptTaxAmount,
        "receiptPrintForm": "Receipt48"
      });

      request.headers.addAll(headers);
      print("createReceipt API Url ---> $url");
      print("Request Body ---> ${request.body}");

      // Send the request
      http.StreamedResponse response = await request.send();

      print("Response Status Code ---> ${response.statusCode}");

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        final body = jsonDecode(responseBody);
        print('Receipt statusCode : ${response.statusCode}');

        String qrUrl = body['qrUrl'] ?? "";
        print('AppConstant singleInvoiceQrURL: qrUrl: $singleInvoiceQrURL');
        // Validate index and ensure qrUrlList has enough slots
        if (index >= qrUrlList.length) {
          qrUrlList.addAll(List<String?>.filled(index - qrUrlList.length + 1, null));
        }
        qrUrlList[index] = qrUrl; // Store qrUrl at the corresponding index
        qrUrlList.refresh(); // 🔥 This ensures ListView updates
        print('Receipt created successfully for index: $index, qrUrl: $qrUrl');
        print('AppConstant singleInvoiceQrURL: $index, qrUrl: $singleInvoiceQrURL');

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

  /// new client requirements calculation
  double _calculateTax(InvoiceModel model) {
    double totalTax = model.items.fold(0.0, (sum, item) {
      final total = double.tryParse(item.price) ?? 0.0; // Assume item.price is receiptLineTotal
      final taxPercent = item.taxPercentage is String
          ? double.tryParse(item.taxPercentage) ?? 0.0
          : (item.taxPercentage as num).toDouble();
      if (taxPercent == 0) return sum; // Skip exempt or 0% tax items
      return sum + (total * taxPercent / (100 + taxPercent));
    });
    return (totalTax * 100).round() / 100; // Round to 2 decimal places
  }

/// hive implementation for the qr Url List
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

  //////////////////////////
  Future<void> loadQrUrlsFromHive(String username) async {
    var box = await Hive.openBox<QrUrlsModel>('qrUrls');
    final qrModel = box.get(username);
    if (qrModel != null) {
      // qrUrlList.assignAll(qrModel.qrUrls);
      qrUrlList.assignAll(qrModel.qrUrls.map((e) => e?.toString()));

      print('Loaded QR URLs from Hive for $username: ${qrUrlList}');
    } else {
      qrUrlList.clear();
      print('No QR URLs found in Hive for $username');
    }
  }


  ///////////////////////////
  Future<void> clearQrUrlsFromHive() async {
    var box = await Hive.openBox<QrUrlsModel>('qrUrls');
    String? username = await getLoggedInUsername();
    if (username != null) {
      await box.delete(username);
      qrUrlList.clear();
      print('Cleared QR URLs in Hive for $username');
    }else {
      print('Not Cleared logged in user not found.');
    }
  }


}
