/// Response from GET `/api/v1/client/receipts?deviceId=&page=&size=`
class ProcessedReceiptsPageResponse {
  final List<ProcessedReceipt> content;
  final PageableInfo? pageable;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int size;
  final int number;
  final int numberOfElements;
  final bool first;
  final bool empty;

  ProcessedReceiptsPageResponse({
    required this.content,
    this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  factory ProcessedReceiptsPageResponse.fromJson(Map<String, dynamic> json) {
    return ProcessedReceiptsPageResponse(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((e) => ProcessedReceipt.fromJson(e as Map<String, dynamic>))
          .toList(),
      pageable: json['pageable'] != null
          ? PageableInfo.fromJson(json['pageable'] as Map<String, dynamic>)
          : null,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      last: json['last'] as bool? ?? true,
      size: (json['size'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt() ?? 0,
      numberOfElements: (json['numberOfElements'] as num?)?.toInt() ?? 0,
      first: json['first'] as bool? ?? true,
      empty: json['empty'] as bool? ?? true,
    );
  }
}

class PageableInfo {
  final SortInfo? sort;
  final int pageNumber;
  final int pageSize;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageableInfo({
    this.sort,
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageableInfo.fromJson(Map<String, dynamic> json) {
    return PageableInfo(
      sort: json['sort'] != null
          ? SortInfo.fromJson(json['sort'] as Map<String, dynamic>)
          : null,
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      paged: json['paged'] as bool? ?? false,
      unpaged: json['unpaged'] as bool? ?? false,
    );
  }
}

class SortInfo {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  SortInfo({required this.sorted, required this.empty, required this.unsorted});

  factory SortInfo.fromJson(Map<String, dynamic> json) {
    return SortInfo(
      sorted: json['sorted'] as bool? ?? false,
      empty: json['empty'] as bool? ?? true,
      unsorted: json['unsorted'] as bool? ?? true,
    );
  }
}

class ProcessedReceipt {
  final String receiptType;
  final String receiptCurrency;
  final int? receiptCounter;
  final int? receiptGlobalNo;
  final String invoiceNo;
  final String receiptDate;
  final bool receiptLinesTaxInclusive;
  final double receiptTotal;
  final double receiptTaxAmount;
  final String receiptPrintForm;
  final String? receiptNotes;
  final CreditDebitNoteReceipt? creditDebitNote;
  final BuyerDataReceipt buyerData;
  final List<ReceiptLineReceipt> receiptLines;
  final List<ReceiptPaymentReceipt> receiptPayments;
  final String? qrUrl; // ✅ NEW FIELD

  ProcessedReceipt({
    required this.receiptType,
    required this.receiptCurrency,
    this.receiptCounter,
    this.receiptGlobalNo,
    required this.invoiceNo,
    required this.receiptDate,
    required this.receiptLinesTaxInclusive,
    required this.receiptTotal,
    required this.receiptTaxAmount,
    required this.receiptPrintForm,
    this.receiptNotes,
    this.creditDebitNote,
    required this.buyerData,
    required this.receiptLines,
    required this.receiptPayments,
    this.qrUrl, // ✅ ADD HERE
  });

  factory ProcessedReceipt.fromJson(Map<String, dynamic> json) {
    return ProcessedReceipt(
      receiptType: json['receiptType']?.toString() ?? '',
      receiptCurrency: json['receiptCurrency']?.toString() ?? '',
      receiptCounter: (json['receiptCounter'] as num?)?.toInt(),
      receiptGlobalNo: (json['receiptGlobalNo'] as num?)?.toInt(),
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      receiptDate: json['receiptDate']?.toString() ?? '',
      receiptLinesTaxInclusive:
      json['receiptLinesTaxInclusive'] as bool? ?? false,
      receiptTotal: _toDouble(json['receiptTotal']),
      receiptTaxAmount: _toDouble(json['receiptTaxAmount']),
      receiptPrintForm: json['receiptPrintForm']?.toString() ?? '',
      receiptNotes: json['receiptNotes']?.toString(),
      creditDebitNote: json['creditDebitNote'] != null
          ? CreditDebitNoteReceipt.fromJson(
          json['creditDebitNote'] as Map<String, dynamic>)
          : null,
      buyerData: BuyerDataReceipt.fromJson(
          json['buyerData'] as Map<String, dynamic>? ?? {}),
      receiptLines: (json['receiptLines'] as List<dynamic>? ?? [])
          .map((e) => ReceiptLineReceipt.fromJson(e as Map<String, dynamic>))
          .toList(),
      receiptPayments: (json['receiptPayments'] as List<dynamic>? ?? [])
          .map((e) => ReceiptPaymentReceipt.fromJson(e as Map<String, dynamic>))
          .toList(),
      qrUrl: json['qrUrl']?.toString(), // ✅ MAP HERE
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

class CreditDebitNoteReceipt {
  final int? deviceID;
  final int? receiptGlobalNo;
  final int? fiscalDayNo;
  final String? originalInvoice;

  CreditDebitNoteReceipt({
    this.deviceID,
    this.receiptGlobalNo,
    this.fiscalDayNo,
    this.originalInvoice,
  });

  factory CreditDebitNoteReceipt.fromJson(Map<String, dynamic> json) {
    return CreditDebitNoteReceipt(
      deviceID: (json['deviceID'] as num?)?.toInt(),
      receiptGlobalNo: (json['receiptGlobalNo'] as num?)?.toInt(),
      fiscalDayNo: (json['fiscalDayNo'] as num?)?.toInt(),
      originalInvoice: json['originalInvoice']?.toString(),
    );
  }
}

class BuyerDataReceipt {
  final String buyerRegisterName;
  final String buyerTIN;
  final dynamic buyerContacts;
  final dynamic buyerAddress;
  final String? vatNumber;

  BuyerDataReceipt({
    required this.buyerRegisterName,
    required this.buyerTIN,
    this.buyerContacts,
    this.buyerAddress,
    this.vatNumber,
  });

  factory BuyerDataReceipt.fromJson(Map<String, dynamic> json) {
    return BuyerDataReceipt(
      buyerRegisterName: json['buyerRegisterName']?.toString() ?? '',
      buyerTIN: json['buyerTIN']?.toString() ?? '',
      buyerContacts: json['buyerContacts'],
      buyerAddress: json['buyerAddress'],
      vatNumber: json['VATNumber']?.toString() ?? json['buyerVAT']?.toString(),
    );
  }
}

class ReceiptLineReceipt {
  final String receiptLineHSCode;
  final String receiptLineType;
  final int receiptLineNo;
  final String receiptLineName;
  final double receiptLineQuantity;
  final double receiptLineTotal;
  final double taxPercent;
  final int taxID;

  ReceiptLineReceipt({
    required this.receiptLineHSCode,
    required this.receiptLineType,
    required this.receiptLineNo,
    required this.receiptLineName,
    required this.receiptLineQuantity,
    required this.receiptLineTotal,
    required this.taxPercent,
    required this.taxID,
  });

  factory ReceiptLineReceipt.fromJson(Map<String, dynamic> json) {
    return ReceiptLineReceipt(
      receiptLineHSCode: json['receiptLineHSCode']?.toString() ?? '',
      receiptLineType: json['receiptLineType']?.toString() ?? '',
      receiptLineNo: (json['receiptLineNo'] as num?)?.toInt() ?? 0,
      receiptLineName: json['receiptLineName']?.toString() ?? '',
      receiptLineQuantity: _toDouble(json['receiptLineQuantity']),
      receiptLineTotal: _toDouble(json['receiptLineTotal']),
      taxPercent: _toDouble(json['taxPercent']),
      taxID: (json['taxID'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReceiptPaymentReceipt {
  final String moneyTypeCode;
  final double paymentAmount;

  ReceiptPaymentReceipt({
    required this.moneyTypeCode,
    required this.paymentAmount,
  });

  factory ReceiptPaymentReceipt.fromJson(Map<String, dynamic> json) {
    return ReceiptPaymentReceipt(
      moneyTypeCode: json['moneyTypeCode']?.toString() ?? '',
      paymentAmount: _toDouble(json['paymentAmount']),
    );
  }
}
