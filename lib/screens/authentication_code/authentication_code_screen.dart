import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class AuthenticationCodeScreen extends StatefulWidget {
  @override
  _AuthenticationCodeScreenState createState() => _AuthenticationCodeScreenState();
}

class _AuthenticationCodeScreenState extends State<AuthenticationCodeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _otpController = TextEditingController();
  int _resendTime = 30;
  bool _canResend = false;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Khởi tạo hiệu ứng fade
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_animationController);
  }

  void _startResendTimer() {
    setState(() {
      _resendTime = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTime > 0) {
        setState(() {
          _resendTime--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  void _verifyOTP(String otp) {
    if (otp.length == 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xác thực thành công!", style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _resendOTP() {
    if (_canResend) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mã OTP mới đã được gửi!", style: TextStyle(fontSize: 16)),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
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
        title: Text("Xác thực OTP"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nhập mã OTP được gửi đến gmail của bạn",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),

            // Ô nhập OTP
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
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: _verifyOTP, // Tự động xác thực khi đủ 6 số
            ),

            SizedBox(height: 20),

            // Hiệu ứng chớp nháy cho gửi lại mã
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
