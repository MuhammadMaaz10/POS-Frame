class invoicePdfPreviewModel {
  String? receiptType;
  String? receiptCurrency;
  int? receiptGlobalNo;
  String? invoiceNo;
  BuyerData? buyerData;
  bool? receiptLinesTaxInclusive;
  List<ReceiptLines>? receiptLines;
  List<ReceiptPayments>? receiptPayments;
  double? receiptTotal;
  double? receiptTaxAmount;
  String? receiptPrintForm;

  invoicePdfPreviewModel(
      {this.receiptType,
        this.receiptCurrency,
        this.receiptGlobalNo,
        this.invoiceNo,
        this.buyerData,
        this.receiptLinesTaxInclusive,
        this.receiptLines,
        this.receiptPayments,
        this.receiptTotal,
        this.receiptTaxAmount,
        this.receiptPrintForm});

  invoicePdfPreviewModel.fromJson(Map<String, dynamic> json) {
    receiptType = json['receiptType'];
    receiptCurrency = json['receiptCurrency'];
    receiptGlobalNo = json['receiptGlobalNo'];
    invoiceNo = json['invoiceNo'];
    buyerData = json['buyerData'] != null
        ? new BuyerData.fromJson(json['buyerData'])
        : null;
    receiptLinesTaxInclusive = json['receiptLinesTaxInclusive'];
    if (json['receiptLines'] != null) {
      receiptLines = <ReceiptLines>[];
      json['receiptLines'].forEach((v) {
        receiptLines!.add(new ReceiptLines.fromJson(v));
      });
    }
    if (json['receiptPayments'] != null) {
      receiptPayments = <ReceiptPayments>[];
      json['receiptPayments'].forEach((v) {
        receiptPayments!.add(new ReceiptPayments.fromJson(v));
      });
    }
    receiptTotal = json['receiptTotal'];
    receiptTaxAmount = json['receiptTaxAmount'];
    receiptPrintForm = json['receiptPrintForm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['receiptType'] = this.receiptType;
    data['receiptCurrency'] = this.receiptCurrency;
    data['receiptGlobalNo'] = this.receiptGlobalNo;
    data['invoiceNo'] = this.invoiceNo;
    if (this.buyerData != null) {
      data['buyerData'] = this.buyerData!.toJson();
    }
    data['receiptLinesTaxInclusive'] = this.receiptLinesTaxInclusive;
    if (this.receiptLines != null) {
      data['receiptLines'] = this.receiptLines!.map((v) => v.toJson()).toList();
    }
    if (this.receiptPayments != null) {
      data['receiptPayments'] =
          this.receiptPayments!.map((v) => v.toJson()).toList();
    }
    data['receiptTotal'] = this.receiptTotal;
    data['receiptTaxAmount'] = this.receiptTaxAmount;
    data['receiptPrintForm'] = this.receiptPrintForm;
    return data;
  }
}

class BuyerData {
  String? buyerRegisterName;
  String? buyerTIN;
  String? buyerVAT;
  BuyerAddress? buyerAddress;

  BuyerData({this.buyerRegisterName, this.buyerTIN, this.buyerVAT, this.buyerAddress});

  BuyerData.fromJson(Map<String, dynamic> json) {
    buyerRegisterName = json['buyerRegisterName'];
    buyerTIN = json['buyerTIN'];
    buyerVAT = json['buyerVAT'];
    buyerAddress = json['buyerAddress'] != null
        ? new BuyerAddress.fromJson(json['buyerAddress'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buyerRegisterName'] = this.buyerRegisterName;
    data['buyerTIN'] = this.buyerTIN;
    data['buyerVAT'] = this.buyerVAT;
    if (this.buyerAddress != null) {
      data['buyerAddress'] = this.buyerAddress!.toJson();
    }
    return data;
  }
}

class BuyerAddress {
  String? houseNumber;
  String? street;
  String? city;
  String? province;

  BuyerAddress({this.houseNumber, this.street, this.city, this.province});

  BuyerAddress.fromJson(Map<String, dynamic> json) {
    houseNumber = json['houseNumber'];
    street = json['street'];
    city = json['city'];
    province = json['province'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['houseNumber'] = this.houseNumber;
    data['street'] = this.street;
    data['city'] = this.city;
    data['province'] = this.province;
    return data;
  }
}

class ReceiptLines {
  String? receiptLineHSCode;
  String? receiptLineType;
  int? receiptLineNo;
  String? receiptLineName;
  int? receiptLineQuantity;
  double? receiptLineTotal;
  double? taxPercent;
  String? taxID;

  ReceiptLines(
      {this.receiptLineHSCode,
        this.receiptLineType,
        this.receiptLineNo,
        this.receiptLineName,
        this.receiptLineQuantity,
        this.receiptLineTotal,
        this.taxPercent,
        this.taxID});

  ReceiptLines.fromJson(Map<String, dynamic> json) {
    receiptLineHSCode = json['receiptLineHSCode'];
    receiptLineType = json['receiptLineType'];
    receiptLineNo = json['receiptLineNo'];
    receiptLineName = json['receiptLineName'];
    receiptLineQuantity = json['receiptLineQuantity'];
    receiptLineTotal = json['receiptLineTotal'];
    taxPercent = json['taxPercent'];
    taxID = json['taxID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['receiptLineHSCode'] = this.receiptLineHSCode;
    data['receiptLineType'] = this.receiptLineType;
    data['receiptLineNo'] = this.receiptLineNo;
    data['receiptLineName'] = this.receiptLineName;
    data['receiptLineQuantity'] = this.receiptLineQuantity;
    data['receiptLineTotal'] = this.receiptLineTotal;
    data['taxPercent'] = this.taxPercent;
    data['taxID'] = this.taxID;
    return data;
  }
}

class ReceiptPayments {
  String? moneyTypeCode;
  int? paymentAmount;

  ReceiptPayments({this.moneyTypeCode, this.paymentAmount});

  ReceiptPayments.fromJson(Map<String, dynamic> json) {
    moneyTypeCode = json['moneyTypeCode'];
    paymentAmount = json['paymentAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['moneyTypeCode'] = this.moneyTypeCode;
    data['paymentAmount'] = this.paymentAmount;
    return data;
  }
}
