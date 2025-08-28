import 'dart:async';
import 'dart:convert';
import 'package:frame_virtual_fiscilation/constants/urls.dart';
import 'package:frame_virtual_fiscilation/presentation/fiscal_device_management/model/fiscal_device_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FiscalDeviceManagementController extends GetxController {
  var isDayOpen = false.obs;
  var isServerOnline = true.obs;
  var dayNumber = 1.obs;
  var countdownDuration = Duration(hours: 24).obs;
  var countdownText = "24:00:00".obs;
  Timer? _timer;

  final int totalSeconds = 24 * 60 * 60; // 24 hours in seconds
  var progress = 1.0.obs; // for progress bar (1.0 = full)

  @override
  void onInit() {
    super.onInit();
    _startCountdownTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    countdownDuration.value = Duration(seconds: totalSeconds);
    progress.value = 1.0;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownDuration.value.inSeconds > 0) {
        countdownDuration.value -= const Duration(seconds: 1);

        // update text
        countdownText.value = _formatDuration(countdownDuration.value);

        // update progress
        progress.value = countdownDuration.value.inSeconds / totalSeconds;
      } else {
        timer.cancel();
        countdownText.value = "00:00:00";
        progress.value = 0.0;
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  /// Setters loading for fiscalDay API
  var isLoading = false;
  void _setLoading(bool value) => isLoading = value;

  /// Setters loading for openDay API
  var isLoading2 = false;
  void _setLoading2(bool value) {
    isLoading2 = value;
    update(); // <-- This triggers the GetBuilder to rebuild
  }

  /// Setters loading for closeDay API
  var isLoading3 = false;
  void _setLoading3(bool value) {
    isLoading3 = value;
    update(); // <-- This triggers the GetBuilder to rebuild
  }

  FiscalDeviceModel? fiscalDayModel;

  /// Function to verify the OTP
  Future<void> getFiscalDayData()
  async {
    _setLoading(true);
    print("🔄 Starting getFiscalDay API...");
    try {
      final url = Uri.parse(baseUrl+getFiscalDayUrl);
      print("🌐 API URL: $url");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "apiKey": "6ec430c2-9aa1-456a-a265-271c517d31da"
        },
      );

      print("📡 getFiscalDay  Status Code: ${response.statusCode}");


      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        print("✅ getFiscalDay Response: ${response.body}");

        // Create instance of your model and store API response
         fiscalDayModel = FiscalDeviceModel.fromJson(data);

        // Optionally store it in a variable for later use
        // this.fiscalDayModel = fiscalDayData;
        print("📦 Model instance created: ${fiscalDayModel?.fiscalDayStatus}");
        update();
      } else {
        print("❌ getFiscalDay  Status Code: ${response.statusCode}");
        print("❌ getFiscalDay Response: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception during getFiscalDay: $e");
    } finally {
      _setLoading(false);
    }
  }


  /// Function of openDay
  Future<void> openDay({required String day})
  async {
    _setLoading2(true);
    print("XXXXXXXXXXXXXX 🔄 Starting openDay API call... XXXXXXXXXXXXXXXXXXX");
    try {
      final url = Uri.parse(baseUrl+openDayUrl+day);
      print("🌐 API URL: $url");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "apiKey": "6ec430c2-9aa1-456a-a265-271c517d31da"
        },
      );

      print("📡 openDay  Status Code: ${response.statusCode}");


      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        print("✅ openDay Response: ${response.body}");
        getFiscalDayData();

      } else {
        print("❌ Failed openDay Response: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception during openDay: $e");
    } finally {
      _setLoading2(false);
    }
  }


  /// Function of closeDay
  Future<void> closeDay({required String day})
  async {
    _setLoading3(true);
    print("🔄 Starting closeDay api call...");
    try {
      final url = Uri.parse(baseUrl+closeDayUrl+day);
      print("🌐 API URL: $url");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print("📡 closeDay  Status Code: ${response.statusCode}");
      print("📩 closeDay Response: ${response.body}");

      if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        print("✅ closeDay Successfully: $data");
        getFiscalDayData();
      } else {
        print("❌ Failed closeDay Response: ${response.body}");
        getFiscalDayData();
      }
    } catch (e) {
      print("⚠️ Exception during closeDay: $e");
    } finally {
      _setLoading3(false);
    }
  }



}
