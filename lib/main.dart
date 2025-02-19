import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart'; // Import file login_screen.dart
import 'screens/auth/register_screen.dart'; // Import file register_screen.dart
import 'screens/auth/forgot_password_screen.dart'; // Import file forgot_password_screen.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      title: 'Đồ án tốt nghiệp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Thêm font mặc định nếu cần
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Border radius mặc định cho TextField
          ),
          prefixIconColor: Colors.blueAccent, // Màu mặc định cho prefixIcon
        ),
      ),
      initialRoute: '/login', // Màn hình khởi đầu
      routes: {
        '/login': (context) => const LoginScreen(), // Định nghĩa route cho LoginScreen
        '/register': (context) => const RegisterScreen(), // Định nghĩa route cho RegisterScreen
        '/forgot_password': (context) => const ForgotPasswordScreen(), // Định nghĩa route cho ForgotPasswordScreen
      },
    );
  }
}