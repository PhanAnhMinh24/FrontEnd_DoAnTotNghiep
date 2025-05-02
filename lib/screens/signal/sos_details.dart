import 'dart:convert';
import 'package:doantotnghiep/global/global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosDetailsScreen extends StatefulWidget {
  static const String route = '/sos_details';
  final int id; // ID của tín hiệu SOS

  const SosDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  _SosDetailsScreenState createState() => _SosDetailsScreenState();
}

class _SosDetailsScreenState extends State<SosDetailsScreen> {
  late Map<String, dynamic> sosDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSosDetails(widget.id); // <- Gọi API lấy dữ liệu
  }

  // Hàm lấy chi tiết SOS từ API
  Future<void> _fetchSosDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Token không hợp lệ hoặc hết hạn
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Token không hợp lệ, vui lòng đăng nhập lại")),
      );
      return;
    }

    final String apiUrl = "http://10.0.2.2:8088/api/sos-alerts/$id";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X_token": globalFcmToken ?? '',
        },
      );

      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['results'] != null) {
        setState(() {
          sosDetails = responseData['results'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData["message"] ?? "Không thể lấy dữ liệu")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết tín hiệu SOS", style: GoogleFonts.poppins()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Thông tin chung"),
                    const SizedBox(height: 10),
                    buildRow(
                        "ID", sosDetails['id'].toString(), LucideIcons.hash),
                    const Divider(height: 24),
                    buildRow("Nội dung", sosDetails['message'] ?? '',
                        LucideIcons.messageCircle),
                    const Divider(height: 24),
                    buildRow(
                        "Thời gian gửi",
                        sosDetails['timeAnnouncement'] ?? '',
                        LucideIcons.clock),
                    const Divider(height: 24),
                    buildRow(
                        "Số cảnh báo",
                        sosDetails['numberAlert'].toString(),
                        LucideIcons.alertTriangle),
                    const Divider(height: 24),
                    _buildSectionTitle("Trạng thái"),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 18),
                      decoration: BoxDecoration(
                        color: (sosDetails['active'] == true)
                            ? Colors.green.withOpacity(0.12)
                            : Colors.red.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (sosDetails['active'] == true)
                                ? LucideIcons.checkCircle2
                                : LucideIcons.xCircle,
                            size: 26,
                            color: (sosDetails['active'] == true)
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            (sosDetails['active'] == true)
                                ? "Đang hoạt động"
                                : "Đã ngừng",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: (sosDetails['active'] == true)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
        letterSpacing: 0.2,
      ),
    );
  }
}
