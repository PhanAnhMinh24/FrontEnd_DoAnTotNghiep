import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CreatedSignalsListScreen extends StatefulWidget {
  const CreatedSignalsListScreen({Key? key}) : super(key: key);

  @override
  _CreatedSignalsListScreenState createState() =>
      _CreatedSignalsListScreenState();
}

class _CreatedSignalsListScreenState extends State<CreatedSignalsListScreen> {
  List<SosAlert> signals = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchSignals();
  }

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      return "Không xác định";
    }
  }

  Future<void> fetchSignals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      debugPrint("Bạn chưa đăng nhập!");
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8088/api/sos-alerts/list');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);

        debugPrint("JSON results: ${data['results']}");

        setState(() {
          final results = data['results'] as List<dynamic>?;

          if (results != null) {
            signals = results.map((json) => SosAlert.fromJson(json)).toList();
          } else {
            signals = [];
          }
          _isLoaded = true;
        });
      } else {
        debugPrint('Lỗi: ${response.statusCode}');
        setState(() => _isLoaded = true);
      }
    } catch (e) {
      debugPrint('Lỗi kết nối hoặc giải mã dữ liệu: $e');
      setState(() => _isLoaded = true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Danh sách tín hiệu đã tạo",
          style: GoogleFonts.poppins(color: CupertinoColors.activeBlue),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.refresh, color: CupertinoColors.activeBlue),
          onPressed: () {
            setState(() => _isLoaded = false);
            fetchSignals();
          },
        ),
      ),
      child: SafeArea(
        child: _isLoaded
            ? (signals.isEmpty
            ? Center(
          child: Text(
            "Chưa có tín hiệu nào được tạo",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: signals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final signal = signals[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.activeBlue.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signal.message,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Thời gian: ${formatDateTime(signal.timeAnnouncement)}",
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: CupertinoColors.black.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Số lượng cảnh báo: ${signal.numberAlert}",
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: CupertinoColors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ))
            : const Center(
          child: CupertinoActivityIndicator(
            color: CupertinoColors.activeBlue,
          ),
        ),
      ),
    );
  }
}

class SosAlert {
  final int id;
  final String message;
  final String timeAnnouncement;
  final int numberAlert;
  final bool active;

  SosAlert({
    required this.id,
    required this.message,
    required this.timeAnnouncement,
    required this.numberAlert,
    required this.active,
  });

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      timeAnnouncement: json['timeAnnouncement'] ?? '',
      numberAlert: json['numberAlert'] ?? 0,
      active: json['active'] ?? false,
    );
  }
}
