import 'dart:convert';

import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/store_invoices/model/processed_receipts_page_response.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProcessedReceiptsController extends GetxController {
  static const int pageSize = 10;

  final receipts = <ProcessedReceipt>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final totalElements = 0.obs;
  final totalPages = 0.obs;
  final hasMore = true.obs;
  int _currentPage = 0;

  int? get _deviceId {
    final id = fiscalDeviceID.trim();
    if (id.isEmpty) return null;
    return int.tryParse(id);
  }

  String get _apiKey =>
      fiscalApiKey.isNotEmpty ? fiscalApiKey : 'd0c64961-34c1-4b3a-9ee2-ffb35c096af7';

  Future<void> refreshReceipts() async {
    _currentPage = 0;
    receipts.clear();
    hasMore.value = true;
    await loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    final deviceId = _deviceId;
    if (deviceId == null) {
      errorMessage.value = 'Fiscal device ID is not configured';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final uri = Uri.parse(
        receiptsListUrl(deviceId: deviceId, page: 0, size: pageSize),
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final page = ProcessedReceiptsPageResponse.fromJson(decoded);
        receipts.assignAll(page.content);
        totalElements.value = page.totalElements;
        totalPages.value = page.totalPages;
        hasMore.value = !page.last && page.content.isNotEmpty;
        _currentPage = page.number;
      } else {
        errorMessage.value =
            'Failed to load receipts (${response.statusCode})';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load receipts';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;

    final deviceId = _deviceId;
    if (deviceId == null) return;

    final nextPage = _currentPage + 1;
    if (totalPages.value > 0 && nextPage >= totalPages.value) {
      hasMore.value = false;
      return;
    }

    isLoadingMore.value = true;
    try {
      final uri = Uri.parse(
        receiptsListUrl(deviceId: deviceId, page: nextPage, size: pageSize),
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'apiKey': _apiKey,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final page = ProcessedReceiptsPageResponse.fromJson(decoded);
        receipts.addAll(page.content);
        totalElements.value = page.totalElements;
        totalPages.value = page.totalPages;
        _currentPage = page.number;
        hasMore.value = !page.last;
      }
    } catch (_) {
      // keep existing list; user can retry via refresh
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }
}
