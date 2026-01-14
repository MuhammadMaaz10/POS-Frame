import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:frame_virtual_fiscilation/local_storage/item_model.dart';
import 'package:frame_virtual_fiscilation/local_storage/company_model.dart';

class StoreInvoicesController extends GetxController {
  // Currency selection
  var selectedCurrency = 'USD'.obs;

  // Selected items with quantities
  var selectedItems = <ItemModel, int>{}.obs;

  // All available items
  var itemList = <ItemModel>[].obs;
  var filteredItemList = <ItemModel>[].obs;

  // Search controller
  final searchController = TextEditingController();

  // Company data
  CompanyModel? companyData;
  var isLoadingCompany = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
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

  void loadItems() async {
    // Static 6 items for demonstration
    itemList.value = [
      ItemModel(
        hsCode: "99001000",
        itemName: "Product A",
        itemCategory: "Electronics",
        itemDescription: "High quality product",
        unitPrice: 29.99,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
      ItemModel(
        hsCode: "99001001",
        itemName: "Product B",
        itemCategory: "Clothing",
        itemDescription: "Premium item",
        unitPrice: 49.99,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
      ItemModel(
        hsCode: "99001002",
        itemName: "Product C",
        itemCategory: "Food",
        itemDescription: "Fresh product",
        unitPrice: 12.50,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
      ItemModel(
        hsCode: "99001003",
        itemName: "Product D",
        itemCategory: "Accessories",
        itemDescription: "Stylish accessory",
        unitPrice: 19.99,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
      ItemModel(
        hsCode: "99001004",
        itemName: "Product E",
        itemCategory: "Home",
        itemDescription: "Home essential",
        unitPrice: 35.00,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
      ItemModel(
        hsCode: "99001005",
        itemName: "Product F",
        itemCategory: "Sports",
        itemDescription: "Sports equipment",
        unitPrice: 79.99,
        vatCategoryName: "Standard",
        vatCategoryPercentage: 15.0,
        vatCategoryID: "2",
      ),
    ];
    filteredItemList.value = itemList;
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      filteredItemList.value = itemList;
    } else {
      filteredItemList.value = itemList
          .where((item) =>
              item.itemName.toLowerCase().contains(query.toLowerCase()) ||
              item.itemCategory.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void updateSelectedCurrency(String? value) {
    if (value != null) {
      selectedCurrency.value = value;
      update();
    }
  }

  void addItem(ItemModel item) {
    if (selectedItems.containsKey(item)) {
      selectedItems[item] = (selectedItems[item] ?? 0) + 1;
    } else {
      selectedItems[item] = 1;
    }
    selectedItems.refresh();
  }

  void removeItem(ItemModel item) {
    if (selectedItems.containsKey(item)) {
      final currentQty = selectedItems[item] ?? 0;
      if (currentQty > 1) {
        selectedItems[item] = currentQty - 1;
      } else {
        selectedItems.remove(item);
      }
      selectedItems.refresh();
    }
  }

  void setItemQuantity(ItemModel item, int quantity) {
    if (quantity <= 0) {
      selectedItems.remove(item);
    } else {
      selectedItems[item] = quantity;
    }
    selectedItems.refresh();
  }

  int getItemQuantity(ItemModel item) {
    return selectedItems[item] ?? 0;
  }

  bool isItemSelected(ItemModel item) {
    return selectedItems.containsKey(item) && (selectedItems[item] ?? 0) > 0;
  }

  double calculateItemTotal(ItemModel item) {
    final quantity = getItemQuantity(item);
    if (quantity == 0) return 0.0;
    
    final unitPrice = item.unitPrice;
    
    // Calculate total (unit price * quantity)
    return unitPrice * quantity;
  }

  double calculateItemTax(ItemModel item) {
    final quantity = getItemQuantity(item);
    if (quantity == 0) return 0.0;
    
    final unitPrice = item.unitPrice;
    final taxPercent = _getTaxPercentage(item);
    final subtotal = unitPrice * quantity;
    return (subtotal * taxPercent) / (100 + taxPercent);
  }

  double calculateItemNet(ItemModel item) {
    final total = calculateItemTotal(item);
    final tax = calculateItemTax(item);
    return total - tax;
  }

  double _getTaxPercentage(ItemModel item) {
    if (item.vatCategoryPercentage is String) {
      return double.tryParse(item.vatCategoryPercentage) ?? 0.0;
    } else if (item.vatCategoryPercentage is num) {
      return item.vatCategoryPercentage.toDouble();
    }
    return 0.0;
  }

  double calculateGrandTotal() {
    double total = 0.0;
    for (var entry in selectedItems.entries) {
      total += calculateItemTotal(entry.key);
    }
    return total;
  }

  double calculateTotalTax() {
    double totalTax = 0.0;
    for (var entry in selectedItems.entries) {
      totalTax += calculateItemTax(entry.key);
    }
    return totalTax;
  }

  double calculateTotalNet() {
    double totalNet = 0.0;
    for (var entry in selectedItems.entries) {
      totalNet += calculateItemNet(entry.key);
    }
    return totalNet;
  }

  int getTotalQuantity() {
    return selectedItems.values.fold<int>(0, (sum, qty) => sum + qty);
  }

  void clearSelection() {
    selectedItems.clear();
    selectedItems.refresh();
  }
}

