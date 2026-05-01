

 import 'app_constants.dart';

String baseUrl = "http://frame-server.af-south-1.elasticbeanstalk.com/api/v1/client/";
String createReceiptUrl = '${baseUrl}receipts/$fiscalDeviceID';

/// GET processed receipts for a device (paginated). [page] is 0-based (Spring).
String receiptsListUrl({required int deviceId, required int page, required int size}) =>
    '${baseUrl}receipts?deviceId=$deviceId&page=$page&size=$size';

 String getFiscalDayUrl = "device-status/$fiscalDeviceID";
 String openDayUrl = "open-day/$fiscalDeviceID";
 String closeDayUrl = "close-day/$fiscalDeviceID";

 String zReportUrl(int deviceId, int fiscalDayNo) => '${baseUrl}z-report/$deviceId/$fiscalDayNo';