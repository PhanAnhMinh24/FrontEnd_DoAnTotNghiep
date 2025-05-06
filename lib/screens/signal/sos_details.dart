import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:doantotnghiep/global/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SosDetailsScreen extends StatefulWidget {
  static const String route = '/sos_details';
  final int id;

  const SosDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  _SosDetailsScreenState createState() => _SosDetailsScreenState();
}

class _SosDetailsScreenState extends State<SosDetailsScreen> {
  Map<String, dynamic>? sosDetails;
  bool _isLoading = true;
  bool _hasConfirmedSafety = false;

  @override
  void initState() {
    super.initState();
    _fetchSosDetails(widget.id);
  }

  Future<void> _fetchSosDetails(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showError("Token không hợp lệ, vui lòng đăng nhập lại");
      return;
    }

    final apiUrl = "http://10.0.2.2:8088/api/sos-alerts/$id";

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
          sosDetails = responseData['results'];
          _hasConfirmedSafety = sosDetails?['userConfirmed'] ?? false;
          _isLoading = false;
        });
      } else {
        _showError(responseData["message"] ?? "Không thể lấy dữ liệu");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Lỗi"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text("Đóng"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _confirmSafety(int id) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Xác nhận an toàn"),
        content: const Text("Bạn có chắc chắn rằng bạn an toàn?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text("Xác nhận"),
            onPressed: () {
              Navigator.pop(context);
              _sendSafetyConfirmation(id);
            },
          ),
        ],
      ),
    );
  }

  void _sendSafetyConfirmation(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showError("Token không hợp lệ, vui lòng đăng nhập lại");
      return;
    }

    final apiUrl = "http://10.0.2.2:8088/api/sos-alerts/confirm/$id";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X_token": globalFcmToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        await _fetchSosDetails(widget.id); // Load lại dữ liệu

        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text("Thành công"),
            content: const Text("Xác nhận an toàn đã được gửi!"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Đóng"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        final Map<String, dynamic> responseData =
        json.decode(utf8.decode(response.bodyBytes));
        _showError(responseData["message"] ?? "Không thể xác nhận an toàn");
      }
    } catch (e) {
      _showError("Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: "Quay lại",
        middle: Text(
          "Chi tiết tín hiệu",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: Container(
        color: CupertinoColors.white,
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 16))
              : sosDetails == null
              ? const Center(child: Text("Không có dữ liệu"))
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/sos_illustration.png',
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Thông tin tín hiệu SOS",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildSectionTitle("Thông tin chung"),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: _buildInfoCard([
                    buildRow("Nội dung",
                        sosDetails!['message'] ?? '', LucideIcons.messageCircle),
                    const Divider(height: 24),
                    buildRow("Thời gian gửi",
                        sosDetails!['timeAnnouncement'] ?? '', LucideIcons.clock),
                    const Divider(height: 24),
                    buildRow("Số cảnh báo",
                        sosDetails!['numberAlert'].toString(), LucideIcons.alertTriangle),
                  ]),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: _buildSectionTitle("Trạng thái"),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: _buildStatusCard(sosDetails!['active'] == true),
                ),
                const SizedBox(height: 28),
                if (!_hasConfirmedSafety && sosDetails!['active'] == true)
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: CupertinoButton(
                      color: CupertinoColors.activeGreen,
                      onPressed: () {
                        _confirmSafety(sosDetails!['id'] ?? 0);
                      },
                      child: const Text("Xác nhận an toàn"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoColors.activeBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: CupertinoColors.activeBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? "Không có dữ liệu" : value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(children: children),
    );
  }

  Widget _buildStatusCard(bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? CupertinoColors.systemGreen.withOpacity(0.15)
            : CupertinoColors.systemRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? CupertinoColors.systemGreen.withOpacity(0.3)
                  : CupertinoColors.systemRed.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
              size: 24,
              color: isActive
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isActive ? "Đang hoạt động" : "Đã ngừng",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: CupertinoColors.systemGrey2,
      ),
    );
  }
}
