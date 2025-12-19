# Invoice Number Generation & Duplicate Invoice Logic

## Overview
This document explains how the `AddInvoicesController` generates invoice numbers for new invoices and handles duplicate invoice creation.

---

## 🔢 Invoice Number Generation Flow

### 1. **Initialization** (On Controller Creation)

```107:119:lib/presentation/add_invoices_screen/controller/add_invoice_controller.dart
  void generateInvoiceNumber() {
    print("---------- generateInvoiceNumber is called ------------ ");
    invoiceNumber.value = 'INV-FR-${_invoiceCounter.toString().padLeft(5, '0')}';
    invoiceNumber2 = 'INV-FR-${_invoiceCounter.toString().padLeft(5, '0')}';
    print("📋 Generated invoice number: ${invoiceNumber.value}");
    print("📋 Generated invoice number 2: ${invoiceNumber2}");
    invoiceIDController.text = invoiceNumber2;
    // invoiceIDController.text = invoiceNumber.value.toString();
    print("📋 Generated invoice number in controller: ${invoiceIDController.text}");
    update();
    _invoiceCounter++;
    // _saveInvoiceCounter();
  }
```

**Steps:**
1. Controller constructor calls `_loadLastInvoiceNumber()`
2. Loads the last saved invoice number from SharedPreferences
3. Extracts the numeric part from the last invoice (format: `INV-FR-XXXXX`)
4. Sets `_invoiceCounter = lastNumber + 1`
5. Generates the first invoice number

**Example:**
- If last invoice was `INV-FR-00005`
- Counter becomes `6`
- Next generated number: `INV-FR-00006`

### 2. **Invoice Number Format**

Format: `INV-FR-{5-digit-number}` (zero-padded)

Examples:
- `INV-FR-00001`
- `INV-FR-00002`
- `INV-FR-00123`
- `INV-FR-12345`

### 3. **Key Components**

- **`_invoiceCounter`**: Internal counter that tracks the next invoice number
- **`invoiceNumber`**: Observable RxString storing the current invoice number
- **`invoiceNumber2`**: String duplicate for form controller
- **`invoiceIDController`**: TextEditingController bound to the UI input field

---

## 📝 Creating a New Invoice

### Process Flow:

```1075:1167:lib/presentation/add_invoices_screen/controller/add_invoice_controller.dart
  void createInvoice() {
    if (selectedCustomer.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a customer",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (dateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select an invoice date",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (dueDateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a due date",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    final selectedItems = selectedItemsWithQuantity.entries.map((entry) {
      return InvoiceItem(
        name: entry.key.itemName,
        category: entry.key.itemCategory,
        price: (entry.key.unitPrice * entry.value).toString(), // total price = unit × quantity
        quantity: entry.value,
        taxName: entry.key.vatCategoryName,
        taxPercentage: entry.key.vatCategoryPercentage,
        taxID: entry.key.vatCategoryID,
          hsCode: entry.key.hsCode

      );
    }).toList();


    createAndSaveInvoice(
      invoiceNo: invoiceNumber.value,
      customerName: selectedCustomer.value!.name,
      customerPic: selectedCustomer.value!.imagePath!,
      customerEmail: selectedCustomer.value!.email,
      customerPhoneNumber: selectedCustomer.value!.phone,
      customerProvinceNumber: selectedCustomer.value!.province,
      customerCityNumber: selectedCustomer.value!.city,
      customerStreetNumber: selectedCustomer.value!.street,
      customerHouseNumber: selectedCustomer.value!.houseNumber,
      customerTinNumber: selectedCustomer.value!.tinNumber,
      customerVatNumber: selectedCustomer.value!.vatNumber,  // ✅ ADD THIS
      items: selectedItems,
      invoiceDate: dateController.text,
      invoiceDueDate: dueDateController.text,
      notes: notesController.text,
      termsAndConditions: addressController.text,
    );

    // ✅ Save latest invoice number
    saveLastInvoiceNumber(invoiceNumber.value);

    // ✅ Generate the next invoice number immediately
    generateInvoiceNumber();


    Get.find<HomeScreenController>().loadInvoice();

    Get.offAll(HomeScreenMain());
    // Simulate invoice generation
    CustomGetSnackBar.show(
      title: "Success",
      message: 'Invoice ${invoiceNumber.value} generated successfully!',
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );




    // // Reset fields after submission
    // generateInvoiceNumber();
    selectedCustomer.value = null;
    selectedItem.value = null;
    dateController.clear();
    invoiceIDController.clear();
    dueDateController.clear();
    notesController.clear();
    addressController.clear();
  }
```

**Steps:**
1. ✅ Validates customer, dates, and items
2. ✅ Creates invoice with current `invoiceNumber.value`
3. ✅ Saves invoice to Hive database
4. ✅ **Saves invoice number to SharedPreferences** via `saveLastInvoiceNumber()`
5. ✅ **Immediately generates next invoice number** via `generateInvoiceNumber()`
6. ✅ Reloads invoice list and navigates to home

### Save Invoice Number Method:

```1171:1178:lib/presentation/add_invoices_screen/controller/add_invoice_controller.dart
  Future<void> saveLastInvoiceNumber(String invoiceNumber) async {
    final prefs = await SharedPreferences.getInstance();
    lastInvoiceNumber = invoiceNumber; // update global variable
    await prefs.setString('lastInvoiceNumber', lastInvoiceNumber);
    print("💾 Saved lastInvoiceNumber globally: $lastInvoiceNumber");
    _loadLastInvoiceNumber();

  }
```

**Note:** This method also calls `_loadLastInvoiceNumber()` which reloads and regenerates, which might cause double-generation. This could be optimized.

---

## 🔄 Duplicate Invoice Creation

### Process Flow:

```1363:1484:lib/presentation/add_invoices_screen/controller/add_invoice_controller.dart
  Future<void> duplicateInvoice() async {
    if (editSelectedCustomer.value == null) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select a customer",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (editDateController.text.isEmpty || editDueDateController.text.isEmpty) {
      CustomGetSnackBar.show(
        title: "Validation Error!",
        message: "Please select invoice and due dates",
        backgroundColor: AppColors.buttonClr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Generate new invoice number
    generateInvoiceNumber(); // Reuse existing method to get new number
    String newInvoiceNo = invoiceNumber.value;
    print("📋 Generated new invoice number for duplicate: $newInvoiceNo");

    // Build updated items (from edits)
    if (selectedItemsWithQuantity.isNotEmpty) {
      editSelectedItem.value = selectedItemsWithQuantity.entries.map((entry) {
        return InvoiceItem(
          name: entry.key.itemName,
          category: entry.key.itemCategory,
          price: (entry.key.unitPrice * entry.value).toString(),
          quantity: entry.value,
          taxName: entry.key.vatCategoryName,
          taxPercentage: entry.key.vatCategoryPercentage,
          taxID: entry.key.vatCategoryID,
          hsCode: entry.key.hsCode,
        );
      }).toList();
    }

    // Calculate new total
    double newTotal = editSelectedItem.fold(0.0, (sum, item) => sum + (double.tryParse(item.price) ?? 0.0));
    print("💸 New total after edits: $newTotal (original: ${originalTotal.value})");

    // Determine InvoiceType based on comparison
    String newInvoiceType = "FiscalInvoice";
    if (newTotal > originalTotal.value) {
      newInvoiceType = "DebitNote";
      print("📈 Invoice type set to Debit (increase in total)");
    } else if (newTotal < originalTotal.value) {
      newInvoiceType = "CreditNote";
      print("📉 Invoice type set to Credit (decrease in total)");
    } else {
      print("⚖️ Invoice type remains Fiscal Invoice (no change in total)");
    }

    // Build new customer
    final newCustomer = InvoiceCustomer(
      name: editSelectedCustomer.value!.name,
      pic: editSelectedCustomer.value!.pic,
      email: editSelectedCustomer.value!.email,
      tinNumber: editSelectedCustomer.value!.tinNumber,
      vatNumber: editSelectedCustomer.value!.vatNumber,  // ✅ ADD THIS
      phoneNumber: editSelectedCustomer.value!.phoneNumber,
      provience: editSelectedCustomer.value!.provience,
      city: editSelectedCustomer.value!.city,
      street: editSelectedCustomer.value!.street,
      houseNumber: editSelectedCustomer.value!.houseNumber,
    );

    print("edit notes -----> ${editNotesController.text}");
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("today date ----> $todayDate");

    // Create new InvoiceModel (with null qrUrl)
    final newInvoice = InvoiceModel(
      invoiceNo: newInvoiceNo,
      customer: newCustomer,
      items: editSelectedItem.value,
      invoiceDate: todayDate,
      // invoiceDate: editDateController.text,
      invoiceDueDate: editDueDateController.text,
      notes: editNotesController.text,
      termsAndConditions: editAddressController.text,
      currency: editSelectedCurrency.value,
      invoiceType: newInvoiceType,
      qrUrl: null, // Explicitly set to null
    );

    // Save to Hive
    var settingsBox = await Hive.openBox('settings');
    var username = settingsBox.get('loggedInUser');
    final invoiceBox = Hive.box<InvoiceModel>('invoices_$username');
    await invoiceBox.add(newInvoice);
    print("✅ Saved new duplicate invoice $newInvoiceNo with type $newInvoiceType and qrUrl: null");

    // ✅ Save last invoice number for persistence
    saveLastInvoiceNumber(newInvoiceNo);

    print("✅ Saved duplicate invoice $newInvoiceNo");

    // ✅ Generate the next invoice number immediately
    generateInvoiceNumber();



    // Reload invoices
    Get.find<HomeScreenController>().loadInvoice();
    Get.offAll(HomeScreenMain());
    selectedItemsWithQuantity.clear();

    CustomGetSnackBar.show(
      title: "Success",
      message: "Duplicate invoice $newInvoiceNo created successfully!",
      backgroundColor: AppColors.buttonClr,
      snackPosition: SnackPosition.TOP,
    );


  }
```

### Key Steps for Duplicate:

1. ✅ **Validates** customer and dates
2. ✅ **Generates new invoice number** using `generateInvoiceNumber()` (line 1385)
3. ✅ **Stores the new number** in `newInvoiceNo` variable
4. ✅ **Builds updated items** from the edit form (if any changes)
5. ✅ **Calculates new total** and compares with original total
6. ✅ **Determines invoice type** automatically:
   - `DebitNote` if new total > original total
   - `CreditNote` if new total < original total
   - `FiscalInvoice` if totals are equal
7. ✅ **Creates new invoice** with:
   - New invoice number
   - Current date (today) as invoice date
   - All edited customer/item data
   - Automatically determined invoice type
   - `qrUrl` set to `null`
8. ✅ **Saves to Hive** database
9. ✅ **Saves invoice number** to SharedPreferences
10. ✅ **Generates next invoice number** immediately for future use

---

## 🔍 Important Observations

### 1. **Invoice Number Generation Logic**

- **Format**: `INV-FR-{5-digit-number}` (zero-padded)
- **Source**: Loaded from SharedPreferences on initialization
- **Counter**: Starts from last saved number + 1
- **Auto-increment**: Counter increments immediately after generation

### 2. **Duplicate Invoice Features**

- ✅ Gets a **new unique invoice number** automatically
- ✅ Uses **today's date** as invoice date (not the original date)
- ✅ **Auto-determines invoice type** based on total comparison:
  - Increase → DebitNote
  - Decrease → CreditNote
  - Same → FiscalInvoice
- ✅ **Preserves all customer and item data** (can be edited before duplicating)
- ✅ Sets `qrUrl` to `null` (new QR code will be generated if needed)

### 3. **Potential Issues/Optimizations**

#### Issue 1: Double Loading in `saveLastInvoiceNumber()`
```1171:1178:lib/presentation/add_invoices_screen/controller/add_invoice_controller.dart
  Future<void> saveLastInvoiceNumber(String invoiceNumber) async {
    final prefs = await SharedPreferences.getInstance();
    lastInvoiceNumber = invoiceNumber; // update global variable
    await prefs.setString('lastInvoiceNumber', lastInvoiceNumber);
    print("💾 Saved lastInvoiceNumber globally: $lastInvoiceNumber");
    _loadLastInvoiceNumber();

  }
```

**Problem**: `_loadLastInvoiceNumber()` is called here, which will:
- Reload from SharedPreferences (which we just saved)
- Generate another invoice number
- This might cause the counter to increment twice

**Recommendation**: Remove `_loadLastInvoiceNumber()` call or make it conditional.

#### Issue 2: Counter Already Incremented
In `generateInvoiceNumber()`, the counter increments AFTER generating the number:
```dart
invoiceNumber.value = 'INV-FR-${_invoiceCounter.toString().padLeft(5, '0')}';
_invoiceCounter++; // Increments immediately after generation
```

This means the next call will use the incremented counter, which is correct behavior.

---

## 📊 Flow Diagram

### New Invoice Creation:
```
Controller Init
    ↓
Load Last Invoice Number (SharedPreferences)
    ↓
Extract Number → Set Counter = LastNumber + 1
    ↓
Generate Invoice Number (Counter used, then Counter++)
    ↓
User Creates Invoice
    ↓
Save Invoice with Generated Number
    ↓
Save Number to SharedPreferences
    ↓
Generate Next Invoice Number (Counter already incremented)
```

### Duplicate Invoice:
```
User Clicks Duplicate
    ↓
Validate Inputs
    ↓
Generate New Invoice Number (Counter used, then Counter++)
    ↓
Calculate New Total vs Original
    ↓
Determine Invoice Type (Debit/Credit/Fiscal)
    ↓
Create New Invoice with:
  - New Invoice Number
  - Today's Date
  - Edited Data
  - Auto-determined Type
    ↓
Save to Database
    ↓
Save Number to SharedPreferences
    ↓
Generate Next Invoice Number
```

---

## 🎯 Summary

### Invoice Number Generation:
- ✅ Sequential numbering: `INV-FR-00001`, `INV-FR-00002`, etc.
- ✅ Persisted in SharedPreferences
- ✅ Auto-increments after each generation
- ✅ Loaded on controller initialization

### Duplicate Invoice:
- ✅ Gets **new unique invoice number** automatically
- ✅ Uses **current date** (not original date)
- ✅ **Smart invoice type detection** based on total changes
- ✅ Preserves all editable data
- ✅ Resets QR code to null

The system ensures **no duplicate invoice numbers** and automatically handles the next available number for both new and duplicated invoices.


