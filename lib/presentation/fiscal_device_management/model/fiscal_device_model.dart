
class FiscalDeviceModel {
  ServerResponse? serverResponse;
  String? lastUsedInvoiceNumber;
  String? timeUntilDayClosure;

  FiscalDeviceModel({
    this.serverResponse,
    this.lastUsedInvoiceNumber,
    this.timeUntilDayClosure,
  });

  /// Factory to create instance from JSON
  factory FiscalDeviceModel.fromJson(Map<String, dynamic> json) {
    return FiscalDeviceModel(
      serverResponse: json['serverResponse'] != null
          ? ServerResponse.fromJson(json['serverResponse'])
          : null,
      lastUsedInvoiceNumber: json['lastUsedInvoiceNumber'],
      timeUntilDayClosure: json['timeUntilDayClosure'],
    );
  }

  /// Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'serverResponse': serverResponse?.toJson(),
      'lastUsedInvoiceNumber': lastUsedInvoiceNumber,
      'timeUntilDayClosure': timeUntilDayClosure,
    };
  }
}

class ServerResponse {
  String? fiscalDayStatus;
  String? fiscalDayReconciliationMode;
  FiscalDayServerSignature? fiscalDayServerSignature;
  String? fiscalDayClosed;
  List<int>? fiscalDayCounter; // ✅ changed from int? to List<int>?
  int? lastFiscalDayNo;
  int? lastReceiptGlobalNo;
  List<FiscalDayDocumentQuantity>? fiscalDayDocumentQuantities; // ✅ changed
  String? operationID;
  dynamic fiscalDayClosingErrorCode;

  ServerResponse({
    this.fiscalDayStatus,
    this.fiscalDayReconciliationMode,
    this.fiscalDayServerSignature,
    this.fiscalDayClosed,
    this.fiscalDayCounter,
    this.lastFiscalDayNo,
    this.lastReceiptGlobalNo,
    this.fiscalDayDocumentQuantities,
    this.operationID,
    this.fiscalDayClosingErrorCode,
  });

  factory ServerResponse.fromJson(Map<String, dynamic> json) {
    return ServerResponse(
      fiscalDayStatus: json['fiscalDayStatus'],
      fiscalDayReconciliationMode: json['fiscalDayReconciliationMode'],
      fiscalDayServerSignature: json['fiscalDayServerSignature'] != null
          ? FiscalDayServerSignature.fromJson(json['fiscalDayServerSignature'])
          : null,
      fiscalDayClosed: json['fiscalDayClosed'],
      fiscalDayCounter: (json['fiscalDayCounter'] as List?)
          ?.map((e) => e as int)
          .toList(),
      lastFiscalDayNo: json['lastFiscalDayNo'],
      lastReceiptGlobalNo: json['lastReceiptGlobalNo'],
      fiscalDayDocumentQuantities: (json['fiscalDayDocumentQuantities'] as List?)
          ?.map((e) => FiscalDayDocumentQuantity.fromJson(e))
          .toList(),
      operationID: json['operationID'],
      fiscalDayClosingErrorCode: json['fiscalDayClosingErrorCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fiscalDayStatus': fiscalDayStatus,
      'fiscalDayReconciliationMode': fiscalDayReconciliationMode,
      'fiscalDayServerSignature': fiscalDayServerSignature?.toJson(),
      'fiscalDayClosed': fiscalDayClosed,
      'fiscalDayCounter': fiscalDayCounter,
      'lastFiscalDayNo': lastFiscalDayNo,
      'lastReceiptGlobalNo': lastReceiptGlobalNo,
      'fiscalDayDocumentQuantities':
      fiscalDayDocumentQuantities?.map((e) => e.toJson()).toList(),
      'operationID': operationID,
      'fiscalDayClosingErrorCode': fiscalDayClosingErrorCode,
    };
  }
}

class FiscalDayServerSignature {
  String? certificateThumbprint;
  String? hash;
  String? signature;

  FiscalDayServerSignature({
    this.certificateThumbprint,
    this.hash,
    this.signature,
  });

  factory FiscalDayServerSignature.fromJson(Map<String, dynamic> json) {
    return FiscalDayServerSignature(
      certificateThumbprint: json['certificateThumbprint'],
      hash: json['hash'],
      signature: json['signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateThumbprint': certificateThumbprint,
      'hash': hash,
      'signature': signature,
    };
  }
}

class FiscalDayDocumentQuantity {
  String? receiptType;
  String? receiptCurrency;
  int? receiptQuantity;
  double? receiptTotalAmount;

  FiscalDayDocumentQuantity({
    this.receiptType,
    this.receiptCurrency,
    this.receiptQuantity,
    this.receiptTotalAmount,
  });

  factory FiscalDayDocumentQuantity.fromJson(Map<String, dynamic> json) {
    return FiscalDayDocumentQuantity(
      receiptType: json['receiptType'],
      receiptCurrency: json['receiptCurrency'],
      receiptQuantity: json['receiptQuantity'],
      receiptTotalAmount: (json['receiptTotalAmount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiptType': receiptType,
      'receiptCurrency': receiptCurrency,
      'receiptQuantity': receiptQuantity,
      'receiptTotalAmount': receiptTotalAmount,
    };
  }
}




// class FiscalDeviceModel {
//   ServerResponse? serverResponse;
//   var lastUsedInvoiceNumber;
//   var timeUntilDayClosure;
//
//   FiscalDeviceModel(
//       {this.serverResponse,
//         this.lastUsedInvoiceNumber,
//         this.timeUntilDayClosure});
//
//   FiscalDeviceModel.fromJson(Map<String, dynamic> json) {
//     serverResponse = json['serverResponse'] != null
//         ? new ServerResponse.fromJson(json['serverResponse'])
//         : null;
//     lastUsedInvoiceNumber = json['lastUsedInvoiceNumber'];
//     timeUntilDayClosure = json['timeUntilDayClosure'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.serverResponse != null) {
//       data['serverResponse'] = this.serverResponse?.toJson();
//     }
//     data['lastUsedInvoiceNumber'] = this.lastUsedInvoiceNumber;
//     data['timeUntilDayClosure'] = this.timeUntilDayClosure;
//     return data;
//   }
// }
//
// class ServerResponse {
//   var fiscalDayStatus;
//   var fiscalDayReconciliationMode;
//   FiscalDayServerSignature? fiscalDayServerSignature;
//   var fiscalDayClosed;
//   var fiscalDayCounter;
//   var lastFiscalDayNo;
//   var lastReceiptGlobalNo;
//   var fiscalDayDocumentQuantities;
//   var operationID;
//   var fiscalDayClosingErrorCode;
//
//   ServerResponse(
//       {this.fiscalDayStatus,
//         this.fiscalDayReconciliationMode,
//         required this.fiscalDayServerSignature,
//         this.fiscalDayClosed,
//         this.fiscalDayCounter,
//         this.lastFiscalDayNo,
//         this.lastReceiptGlobalNo,
//         this.fiscalDayDocumentQuantities,
//         this.operationID,
//         this.fiscalDayClosingErrorCode});
//
//   ServerResponse.fromJson(Map<String, dynamic> json) {
//     fiscalDayStatus = json['fiscalDayStatus'];
//     fiscalDayReconciliationMode = json['fiscalDayReconciliationMode'];
//     fiscalDayServerSignature = (json['fiscalDayServerSignature'] != null
//         ? new FiscalDayServerSignature.fromJson(
//         json['fiscalDayServerSignature'])
//         : null)!;
//     fiscalDayClosed = json['fiscalDayClosed'];
//     fiscalDayCounter = json['fiscalDayCounter'];
//     lastFiscalDayNo = json['lastFiscalDayNo'];
//     lastReceiptGlobalNo = json['lastReceiptGlobalNo'];
//     fiscalDayDocumentQuantities = json['fiscalDayDocumentQuantities'];
//     operationID = json['operationID'];
//     fiscalDayClosingErrorCode = json['fiscalDayClosingErrorCode'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['fiscalDayStatus'] = this.fiscalDayStatus;
//     data['fiscalDayReconciliationMode'] = this.fiscalDayReconciliationMode;
//     if (this.fiscalDayServerSignature != null) {
//       data['fiscalDayServerSignature'] = this.fiscalDayServerSignature?.toJson();
//     }
//     data['fiscalDayClosed'] = this.fiscalDayClosed;
//     data['fiscalDayCounter'] = this.fiscalDayCounter;
//     data['lastFiscalDayNo'] = this.lastFiscalDayNo;
//     data['lastReceiptGlobalNo'] = this.lastReceiptGlobalNo;
//     data['fiscalDayDocumentQuantities'] = this.fiscalDayDocumentQuantities;
//     data['operationID'] = this.operationID;
//     data['fiscalDayClosingErrorCode'] = this.fiscalDayClosingErrorCode;
//     return data;
//   }
// }
//
// class FiscalDayServerSignature {
//   var certificateThumbprint;
//   var hash;
//   var signature;
//
//   FiscalDayServerSignature(
//       {this.certificateThumbprint, this.hash, this.signature});
//
//   FiscalDayServerSignature.fromJson(Map<String, dynamic> json) {
//     certificateThumbprint = json['certificateThumbprint'];
//     hash = json['hash'];
//     signature = json['signature'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['certificateThumbprint'] = this.certificateThumbprint;
//     data['hash'] = this.hash;
//     data['signature'] = this.signature;
//     return data;
//   }
// }

