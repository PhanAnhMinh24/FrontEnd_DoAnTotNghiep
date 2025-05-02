import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:doantotnghiep/screens/signal/sos_details.dart';
import 'package:doantotnghiep/global/global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
          "X_token": globalFcmToken ?? '',
        },
      );

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);

        debugPrint("Decoded JSON: $data");

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


  Future<void> deleteSignal(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      debugPrint("Bạn chưa đăng nhập!");
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8088/api/sos-alerts/$id');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=utf-8',
          "X_token": globalFcmToken ?? '',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Đã xóa tín hiệu $id");
      } else {
        debugPrint('Lỗi khi xóa: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa tín hiệu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final message =
    ModalRoute.of(context)?.settings.arguments as RemoteMessage?;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey6,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Danh sách tín hiệu đã tạo",
          style: GoogleFonts.poppins(
            color: CupertinoColors.activeBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.refresh_circled,
            color: CupertinoColors.activeBlue,
            size: 28,
          ),
          onPressed: () {
            setState(() => _isLoaded = false);
            fetchSignals();
          },
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: _isLoaded
                ? (signals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 60,
                    color: CupertinoColors.systemGrey2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có tín hiệu nào được tạo",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: signals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final signal = signals[index];
                return Dismissible(
                  key: Key(signal.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text(
                          "Xóa tín hiệu",
                          style: GoogleFonts.poppins(),
                        ),
                        content: Text(
                          "Bạn có chắc chắn muốn xóa tín hiệu này không?",
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text("Hủy"),
                            onPressed: () =>
                                Navigator.of(context).pop(false),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text("Xóa"),
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await deleteSignal(signal.id);
                    setState(() => signals.removeAt(index));
                  },
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SosDetailsScreen(id: signal.id),
                            ),
                          );
                        },

                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                CupertinoColors.systemGrey6
                                    .withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.activeBlue
                                    .withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            signal.message,
                                            style:
                                            GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: CupertinoColors
                                                  .activeBlue,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          signal.active
                                              ? CupertinoIcons
                                              .checkmark_circle_fill
                                              : CupertinoIcons
                                              .xmark_circle_fill,
                                          color: signal.active
                                              ? CupertinoColors
                                              .activeGreen
                                              : CupertinoColors
                                              .systemRed,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Thời gian: ${formatDateTime(signal.timeAnnouncement)}",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: CupertinoColors.black
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Số lượng cảnh báo: ${signal.numberAlert}",
                                      style: GoogleFonts.roboto(
                                        fontSize: 14,
                                        color: CupertinoColors.black
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ))
                : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  CupertinoColors.activeBlue,
                ),
                strokeWidth: 3,
              ),
            ),
          ),
          // Floating Action Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: CupertinoColors.activeBlue,
              onPressed: () {
                // Giả định hành động tạo tín hiệu mới
                debugPrint("Tạo tín hiệu mới");
              },
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
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