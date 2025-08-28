class FiscalDeviceModel {
  var fiscalDayStatus;
  var fiscalDayReconciliationMode;
  var fiscalDayServerSignature;
  var fiscalDayClosed;
  var fiscalDayCounter;
  var lastFiscalDayNo;
  var lastReceiptGlobalNo;
  var fiscalDayDocumentQuantities;
  var operationID;
  var fiscalDayClosingErrorCode;

  FiscalDeviceModel(
      {this.fiscalDayStatus,
        this.fiscalDayReconciliationMode,
        this.fiscalDayServerSignature,
        this.fiscalDayClosed,
        this.fiscalDayCounter,
        this.lastFiscalDayNo,
        this.lastReceiptGlobalNo,
        this.fiscalDayDocumentQuantities,
        this.operationID,
        this.fiscalDayClosingErrorCode});

  FiscalDeviceModel.fromJson(Map<String, dynamic> json) {
    fiscalDayStatus = json['fiscalDayStatus'];
    fiscalDayReconciliationMode = json['fiscalDayReconciliationMode'];
    fiscalDayServerSignature = json['fiscalDayServerSignature'];
    fiscalDayClosed = json['fiscalDayClosed'];
    fiscalDayCounter = json['fiscalDayCounter'];
    lastFiscalDayNo = json['lastFiscalDayNo'];
    lastReceiptGlobalNo = json['lastReceiptGlobalNo'];
    fiscalDayDocumentQuantities = json['fiscalDayDocumentQuantities'];
    operationID = json['operationID'];
    fiscalDayClosingErrorCode = json['fiscalDayClosingErrorCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fiscalDayStatus'] = this.fiscalDayStatus;
    data['fiscalDayReconciliationMode'] = this.fiscalDayReconciliationMode;
    data['fiscalDayServerSignature'] = this.fiscalDayServerSignature;
    data['fiscalDayClosed'] = this.fiscalDayClosed;
    data['fiscalDayCounter'] = this.fiscalDayCounter;
    data['lastFiscalDayNo'] = this.lastFiscalDayNo;
    data['lastReceiptGlobalNo'] = this.lastReceiptGlobalNo;
    data['fiscalDayDocumentQuantities'] = this.fiscalDayDocumentQuantities;
    data['operationID'] = this.operationID;
    data['fiscalDayClosingErrorCode'] = this.fiscalDayClosingErrorCode;
    return data;
  }
}
