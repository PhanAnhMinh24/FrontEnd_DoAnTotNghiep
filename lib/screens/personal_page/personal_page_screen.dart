import 'package:flutter/material.dart';
import 'package:doantotnghiep/screens/personal_page/edit_profile_screen.dart';

class PersonalPageScreen extends StatelessWidget {
  const PersonalPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Page"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar đại diện
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://www.example.com/avatar.jpg'), // Thay đổi URL của ảnh đại diện
              ),
              const SizedBox(height: 20),

              // Thông tin người dùng
              const Text(
                "John Doe",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Email: johndoe@example.com",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "Phone: +123456789",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Nút chỉnh sửa thông tin
              ElevatedButton(
                onPressed: () {
                  // Điều hướng đến màn hình chỉnh sửa thông tin cá nhân
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Thay primary bằng backgroundColor
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Thay đổi màu chữ thành trắng
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
