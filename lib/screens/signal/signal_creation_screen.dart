import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doantotnghiep/global/global.dart';

class SignalCreationScreen extends StatefulWidget {
  const SignalCreationScreen({Key? key}) : super(key: key);

  @override
  State<SignalCreationScreen> createState() => _SignalCreationScreenState();
}

class _SignalCreationScreenState extends State<SignalCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _alertCountController = TextEditingController();

  DateTime _timeAnnouncement = DateTime.now();
  bool _active = true;
  bool _isLoading = false;
  int _alertCount = 1;
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _timeController.text = _formatDateTime(_timeAnnouncement);
    _alertCountController.text = '$_alertCount';
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => _token = token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text("Tạo tín hiệu", style: GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 22, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _token == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _messageController, label: 'Nội dung thông báo', validator: (v) => v!.isEmpty ? 'Vui lòng nhập nội dung' : null),
              const SizedBox(height: 16),
              _buildTextField(controller: _timeController, label: 'Chọn thời gian', readOnly: true, onTap: _pickDateTime, suffixIcon: const Icon(Icons.access_time, color: Colors.blueAccent)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _alertCountController,
                label: 'Số lần cảnh báo',
                readOnly: true,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.blueAccent), onPressed: () {
                      if (_alertCount > 1) setState(() {
                        _alertCount--;
                        _alertCountController.text = '$_alertCount';
                      });
                    }),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent), onPressed: () {
                      setState(() {
                        _alertCount++;
                        _alertCountController.text = '$_alertCount';
                      });
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kích hoạt", style: GoogleFonts.poppins(fontSize: 16, color: Colors.blueAccent)),
                  Switch(value: _active, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _active = v)),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitSignal,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Tạo tín hiệu", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.blueAccent), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixIcon: suffixIcon),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timeAnnouncement,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timeAnnouncement),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent, // selected time circle color
              onPrimary: Colors.white, // selected time text color
              onSurface: Colors.black, // default text color
            ),
            timePickerTheme: const TimePickerThemeData(
              hourMinuteColor: Colors.blueAccent,
              hourMinuteTextColor: Colors.white,
              dialHandColor: Colors.blueAccent,
              dialBackgroundColor: Color(0xFFE3F2FD), // optional light blue
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    setState(() {
      _timeAnnouncement = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _timeController.text = _formatDateTime(_timeAnnouncement);
    });
  }


  String _formatDateTime(DateTime dt) => "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";

  Future<void> _submitSignal() async {
    if (!_formKey.currentState!.validate()) { _showDialog("Vui lòng điền đầy đủ thông tin"); return; }
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse("http://10.0.2.2:8088/api/sos-alerts");
      final body = jsonEncode({
        "message": _messageController.text,
        "timeAnnouncement": _timeAnnouncement.toIso8601String(),
        "numberAlert": _alertCount,
        "active": _active
      });
      final response = await http.post(uri, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
        "X_token": globalFcmToken ?? '',
      }, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        debugPrint('CREATE SOS RESPONSE: $responseBody');

        // *** LẤY ID TỪ results ***
        final dynamic rawId = responseBody['results']?['id'];
        if (rawId == null) {
          _showDialog('Server không trả về id của SOS alert.');
          return;
        }
        final int sosAlertId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

        Navigator.pushNamed(context, '/notification_friend_list', arguments: {
          'sosAlertId': sosAlertId,
          'message': _messageController.text,
        });
      } else {
        _showDialog("Lỗi: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      _showDialog("Lỗi kết nối: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showDialog(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Thông báo", style: GoogleFonts.poppins(color: Colors.blueAccent)),
      content: Text(msg, style: GoogleFonts.poppins()),
      actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Đóng", style: GoogleFonts.poppins(color: Colors.blueAccent))) ],
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _timeController.dispose();
    _alertCountController.dispose();
    super.dispose();
  }
}
