import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:doantotnghiep/screens/auth/login_screen.dart'; // Đường dẫn đến màn hình đăng nhập

class AuthenticationCodeScreen extends StatefulWidget {
  final String email;

  const AuthenticationCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _AuthenticationCodeScreenState createState() => _AuthenticationCodeScreenState();
}

class _AuthenticationCodeScreenState extends State<AuthenticationCodeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  int _resendTime = 30;
  bool _canResend = false;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_animationController);
  }

  void _startResendTimer() {
    _resendTime = 30;
    _canResend = false;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTime > 0) {
        setState(() {
          _resendTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  Future<void> _verifyOTP(String otp) async {
    final String apiUrl = "http://10.0.2.2:8088/otp/verify-otp"; // Dùng 10.0.2.2 cho Android Emulator
    final Map<String, String> body = {
      "email": widget.email,
      "verificationCode": otp,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Xác thực thành công!", style: TextStyle(fontSize: 16)),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // ✅ Chuyển đến màn hình đăng nhập nếu OTP đúng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${responseData['message'] ?? 'Mã OTP không hợp lệ!'}",
                style: TextStyle(fontSize: 16)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối: $error", style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resendOTP() async {
    if (_canResend) {
      final String apiUrl =
          "http://10.0.2.2:8088/otp/send-code?email=${Uri.encodeComponent(widget.email)}";

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mã OTP mới đã được gửi!", style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
          _startResendTimer();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gửi mã OTP thất bại: ${response.body}", style: TextStyle(fontSize: 16)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi kết nối! $error", style: TextStyle(fontSize: 16)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Xác thực OTP"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nhập mã OTP được gửi đến ${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                borderRadius: BorderRadius.circular(10),
                fieldHeight: 55,
                fieldWidth: 45,
                activeFillColor: Colors.blue.shade100,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.blue.shade50,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                selectedColor: Colors.blueAccent,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: _verifyOTP,
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: _fadeAnimation,
              child: TextButton(
                onPressed: _canResend ? _resendOTP : null,
                child: Text(
                  _canResend ? "Gửi lại mã OTP" : "Gửi lại sau $_resendTime giây",
                  style: TextStyle(
                    fontSize: 16,
                    color: _canResend ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
