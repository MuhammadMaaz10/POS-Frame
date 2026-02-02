import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/local_storage/company_model.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/inventory_item.dart';

class StoreInvoicesController extends GetxController {
  // Currency selection
  var selectedCurrency = 'USD'.obs;

  // API loading state
  final isLoadingItems = true.obs;
  final errorMessage = RxnString();

  // Selected item quantities by id
  final selectedQuantities = <int, int>{}.obs;

  // Inventory items (from backend)
  final itemList = <InventoryItem>[].obs;
  final filteredItemList = <InventoryItem>[].obs;

  // Search controller
  final searchController = TextEditingController();

  // Company data
  CompanyModel? companyData;
  var isLoadingCompany = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadItemsFromApi();
    loadCompanyData();
    searchController.addListener(() {
      filterItems(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadCompanyData() async {
    try {
      var settingsBox = await Hive.openBox('settings');
      var username = settingsBox.get('loggedInUser');
      
      if (username != null) {
        final box = await Hive.openBox<CompanyModel>('companies_$username');
        if (box.isNotEmpty) {
          companyData = box.values.first;
          isLoadingCompany.value = false;
          return;
        }
      }
    } catch (e) {
      print('Error loading company data: $e');
    }
    isLoadingCompany.value = false;
  }

  /// Loads inventory from backend.
  /// Uses configured apiKey if available, otherwise falls back to demo key.
  Future<void> loadItemsFromApi({int page = 0, int size = 10}) async {
    isLoadingItems.value = true;
    errorMessage.value = null;
    try {
      final apiKeyHeader = (fiscalApiKey.isNotEmpty)
          ? fiscalApiKey
          : 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7';

      final uri = Uri.parse('${baseUrl}inventory?page=$page&size=$size');
      print('[StoreInvoices] GET $uri');
      print(
        '[StoreInvoices] apiKey header: ${apiKeyHeader.isNotEmpty ? '${apiKeyHeader.substring(0, 6)}…' : '(empty)'}',
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'apiKey': apiKeyHeader,
        },
      );

      print('[StoreInvoices] Status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        final preview =
            response.body.length > 1000 ? response.body.substring(0, 1000) : response.body;
        print('[StoreInvoices] Body preview: $preview');
      } else {
        print('[StoreInvoices] Empty response body');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final content = (decoded['content'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        final items = content.map(InventoryItem.fromJson).toList();
        itemList.value = items;
        filteredItemList.value = items;
        print('[StoreInvoices] Parsed items: ${items.length}');
      } else {
        errorMessage.value = 'Failed to load inventory (${response.statusCode})';
        print('[StoreInvoices] Error: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load inventory';
      print('[StoreInvoices] Exception: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItemList.value = itemList;
    } else {
      filteredItemList.value = itemList
          .where((item) =>
              item.itemName.toLowerCase().contains(query.toLowerCase()) ||
              item.itemCode.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void updateSelectedCurrency(String? value) {
    if (value != null) {
      selectedCurrency.value = value;
      update();
    }
  }

  void addItem(InventoryItem item) {
    final current = selectedQuantities[item.id] ?? 0;
    selectedQuantities[item.id] = current + 1;
    selectedQuantities.refresh();
  }

  void removeItem(InventoryItem item) {
    final currentQty = selectedQuantities[item.id] ?? 0;
    if (currentQty <= 1) {
      selectedQuantities.remove(item.id);
    } else {
      selectedQuantities[item.id] = currentQty - 1;
    }
    selectedQuantities.refresh();
  }

  void setItemQuantity(InventoryItem item, int quantity) {
    if (quantity <= 0) {
      selectedQuantities.remove(item.id);
    } else {
      selectedQuantities[item.id] = quantity;
    }
    selectedQuantities.refresh();
  }

  int getItemQuantity(InventoryItem item) {
    return selectedQuantities[item.id] ?? 0;
  }

  bool isItemSelected(InventoryItem item) {
    return (selectedQuantities[item.id] ?? 0) > 0;
  }

  double calculateItemTotal(InventoryItem item, {int? quantity}) {
    final qty = quantity ?? getItemQuantity(item);
    if (qty == 0) return 0.0;
    return item.price * qty;
  }

  /// Tax amount when price is tax-inclusive (same logic used in invoice PDF screen).
  double calculateItemTax(InventoryItem item, {int? quantity}) {
    final qty = quantity ?? getItemQuantity(item);
    if (qty == 0) return 0.0;
    final gross = item.price * qty;
    final taxPercent = item.taxGroup;
    if (taxPercent == 0) return 0.0;
    return (gross * taxPercent) / (100 + taxPercent);
  }

  double calculateItemNet(InventoryItem item, {int? quantity}) {
    final total = calculateItemTotal(item, quantity: quantity);
    final tax = calculateItemTax(item, quantity: quantity);
    return total - tax;
  }

  double calculateGrandTotal() {
    double total = 0.0;
    final byId = {for (final it in itemList) it.id: it};
    for (final entry in selectedQuantities.entries) {
      final item = byId[entry.key];
      if (item == null) continue;
      total += calculateItemTotal(item, quantity: entry.value);
    }
    return total;
  }

  double calculateTotalTax() {
    double totalTax = 0.0;
    final byId = {for (final it in itemList) it.id: it};
    for (final entry in selectedQuantities.entries) {
      final item = byId[entry.key];
      if (item == null) continue;
      totalTax += calculateItemTax(item, quantity: entry.value);
    }
    return totalTax;
  }

  double calculateTotalNet() {
    double totalNet = 0.0;
    final byId = {for (final it in itemList) it.id: it};
    for (final entry in selectedQuantities.entries) {
      final item = byId[entry.key];
      if (item == null) continue;
      totalNet += calculateItemNet(item, quantity: entry.value);
    }
    return totalNet;
  }

  int getTotalQuantity() {
    return selectedQuantities.values.fold<int>(0, (sum, qty) => sum + qty);
  }

  void clearSelection() {
    selectedQuantities.clear();
    selectedQuantities.refresh();
  }
}

