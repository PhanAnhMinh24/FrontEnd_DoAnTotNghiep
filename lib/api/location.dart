import 'dart:async' ;
import 'dart:convert';
import 'package:doantotnghiep/global/global.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Timer? _timer;
  static void startSendingLocation() {
    _timer?.cancel(); // đảm bảo không bị nhân đôi
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      const double lat = 13.759;
      const double lng = 109.218;
      sendLocationToApi(lat, lng);
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> sendLocationToApi(double latitude, double longitude) async {
    final url = Uri.parse('http://10.0.2.2:8088/api/travel_histories/create');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "X_token": globalFcmToken ?? '',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Gửi thành công: $latitude, $longitude');
      } else {
        print('❌ Gửi thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('🚫 Lỗi khi gọi API: $e');
    }
  }
}
