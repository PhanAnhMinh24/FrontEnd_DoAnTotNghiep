import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:doantotnghiep/global/global.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Biến để hiển thị trạng thái loading

  Future<void> _submitNewPassword() async {
    if (_otpController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin!")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Hiển thị trạng thái loading
    });

    final url = Uri.parse("http://10.0.2.2:8088/otp/reset-password");
    final response = await http.post(
      url,
        headers: {
          "Content-Type": "application/json",
          "X_token": globalFcmToken ?? '', // lấy token từ biến global
        },
      body: jsonEncode({
        "email": widget.email,
        "verificationCode": _otpController.text,
        "password": _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false; // Tắt trạng thái loading sau khi có phản hồi
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu của bạn đã được đặt lại thành công!")),
      );
      Navigator.pop(context);
    } else {
      final errorMessage = jsonDecode(response.body)["message"] ?? "Đặt lại mật khẩu thất bại!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đặt lại mật khẩu", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.mail, color: Colors.blueAccent),
                  const SizedBox(width: 10),
                  Text(
                    "Email: ${widget.email}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                controller: _otpController,
                length: 6,
                appContext: context,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                cursorColor: Colors.blue,
                autoDismissKeyboard: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 55,
                  fieldWidth: 45,
                  activeFillColor: Colors.blue.shade50,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.blue.shade100,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blueAccent,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Nhập mật khẩu mới",
                  prefixIcon: const Icon(LucideIcons.lock, color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitNewPassword,
                  icon: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(LucideIcons.check, color: Colors.white),
                  label: Text(
                    _isLoading ? "Đang xử lý..." : "Xác nhận",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
