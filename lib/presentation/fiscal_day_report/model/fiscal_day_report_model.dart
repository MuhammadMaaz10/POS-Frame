class FiscalDayReportModel {
  int? deviceId;
  int? fiscalDayNo;
  String? reportPeriodStart;
  String? reportPeriodEnd;
  String? fiscalDayOpened;
  String? fiscalDayClosed;
  String? deviceSerialNo;
  CompanyInfo? companyInfo;
  Map<String, DailyTotal>? dailyTotals;
  Map<String, List<TaxBreakdown>>? taxBreakdown;
  Map<String, DocumentCounts>? documentCounts;
  Map<String, double>? quantityTotals;
  Map<String, Map<String, double>>? paymentMethods;
  Map<String, Map<String, double>>? balanceCounters;
  List<DocumentInfo>? documents;

  FiscalDayReportModel({
    this.deviceId,
    this.fiscalDayNo,
    this.reportPeriodStart,
    this.reportPeriodEnd,
    this.fiscalDayOpened,
    this.fiscalDayClosed,
    this.deviceSerialNo,
    this.companyInfo,
    this.dailyTotals,
    this.taxBreakdown,
    this.documentCounts,
    this.quantityTotals,
    this.paymentMethods,
    this.balanceCounters,
    this.documents,
  });

  factory FiscalDayReportModel.fromJson(Map<String, dynamic> json) {
    return FiscalDayReportModel(
      deviceId: json['deviceId'],
      fiscalDayNo: json['fiscalDayNo'],
      reportPeriodStart: json['reportPeriodStart'],
      reportPeriodEnd: json['reportPeriodEnd'],
      fiscalDayOpened: json['fiscalDayOpened'],
      fiscalDayClosed: json['fiscalDayClosed'],
      deviceSerialNo: json['deviceSerialNo'],
      companyInfo: json['companyInfo'] != null
          ? CompanyInfo.fromJson(json['companyInfo'])
          : null,
      dailyTotals: json['dailyTotals'] != null
          ? (json['dailyTotals'] as Map<String, dynamic>).map((k, v) =>
              MapEntry(k, DailyTotal.fromJson(v as Map<String, dynamic>)))
          : null,
      taxBreakdown: json['taxBreakdown'] != null
          ? (json['taxBreakdown'] as Map<String, dynamic>).map((k, v) => MapEntry(
              k,
              (v as List).map((i) => TaxBreakdown.fromJson(i)).toList()))
          : null,
      documentCounts: json['documentCounts'] != null
          ? (json['documentCounts'] as Map<String, dynamic>).map((k, v) =>
              MapEntry(k, DocumentCounts.fromJson(v as Map<String, dynamic>)))
          : null,
      quantityTotals: json['quantityTotals'] != null
          ? (json['quantityTotals'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()))
          : null,
      paymentMethods: json['paymentMethods'] != null
          ? (json['paymentMethods'] as Map<String, dynamic>).map((k, v) => MapEntry(
              k,
              (v as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, (value as num).toDouble()))))
          : null,
      balanceCounters: json['balanceCounters'] != null
          ? (json['balanceCounters'] as Map<String, dynamic>).map((k, v) => MapEntry(
              k,
              (v as Map<String, dynamic>).map(
                  (key, value) => MapEntry(key, (value as num).toDouble()))))
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((i) => DocumentInfo.fromJson(i))
              .toList()
          : null,
    );
  }
}

class CompanyInfo {
  String? legalName;
  String? tin;
  String? vatNumber;
  Address? address;

  CompanyInfo({this.legalName, this.tin, this.vatNumber, this.address});

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      legalName: json['legalName'],
      tin: json['tin'],
      vatNumber: json['vatNumber'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }
}

class Address {
  String? province;
  String? city;
  String? street;
  String? houseNo;

  Address({this.province, this.city, this.street, this.houseNo});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      province: json['province'],
      city: json['city'],
      street: json['street'],
      houseNo: json['houseNo'],
    );
  }
}

class DailyTotal {
  double? netSales;
  double? taxAmount;
  double? grossSales;
  double? creditNotes;
  double? debitNotes;

  DailyTotal({
    this.netSales,
    this.taxAmount,
    this.grossSales,
    this.creditNotes,
    this.debitNotes,
  });

  factory DailyTotal.fromJson(Map<String, dynamic> json) {
    return DailyTotal(
      netSales: (json['netSales'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      grossSales: (json['grossSales'] as num?)?.toDouble(),
      creditNotes: (json['creditNotes'] as num?)?.toDouble(),
      debitNotes: (json['debitNotes'] as num?)?.toDouble(),
    );
  }
}

class TaxBreakdown {
  double? taxPercent;
  int? taxID;
  double? salesAmount;
  double? creditNoteAmount;
  double? debitNoteAmount;

  TaxBreakdown({
    this.taxPercent,
    this.taxID,
    this.salesAmount,
    this.creditNoteAmount,
    this.debitNoteAmount,
  });

  factory TaxBreakdown.fromJson(Map<String, dynamic> json) {
    return TaxBreakdown(
      taxPercent: (json['taxPercent'] as num?)?.toDouble(),
      taxID: json['taxID'],
      salesAmount: (json['salesAmount'] as num?)?.toDouble(),
      creditNoteAmount: (json['creditNoteAmount'] as num?)?.toDouble(),
      debitNoteAmount: (json['debitNoteAmount'] as num?)?.toDouble(),
    );
  }
}

class DocumentCounts {
  int? invoices;
  int? creditNotes;
  int? debitNotes;

  DocumentCounts({this.invoices, this.creditNotes, this.debitNotes});

  factory DocumentCounts.fromJson(Map<String, dynamic> json) {
    return DocumentCounts(
      invoices: json['invoices'],
      creditNotes: json['creditNotes'],
      debitNotes: json['debitNotes'],
    );
  }
}

class DocumentInfo {
  String? type;
  String? invoiceNo;
  String? date;
  String? currency;
  double? total;
  double? taxAmount;
  int? globalNo;

  DocumentInfo({
    this.type,
    this.invoiceNo,
    this.date,
    this.currency,
    this.total,
    this.taxAmount,
    this.globalNo,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      type: json['type'],
      invoiceNo: json['invoiceNo'],
      date: json['date'],
      currency: json['currency'],
      total: (json['total'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      globalNo: json['globalNo'],
    );
  }
}
