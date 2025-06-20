import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/local_storage/customer_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/invoice_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../local_storage/item_model.dart';

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
  @override
  void onInit() {
    super.onInit();
    loadItems();
    loadCustomer();
    loadInvoice();

    searchItemController.addListener(() {
      filterItems(searchItemController.text);
    });

    searchCustomerController.addListener(() {
      filterCustomers(searchCustomerController.text);
    });

    searchInvoiceController.addListener(() {
      filterInvoices(searchInvoiceController.text);
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
      total += double.tryParse(invoice.items.price) ?? 0;
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









}
