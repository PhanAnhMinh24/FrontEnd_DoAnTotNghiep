import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:doantotnghiep/screens/personal_page/edit_profile_screen.dart';
import 'package:doantotnghiep/global/global.dart';

class PersonalPageScreen extends StatefulWidget {
  const PersonalPageScreen({super.key});

  @override
  State<PersonalPageScreen> createState() => _PersonalPageScreenState();
}

class _PersonalPageScreenState extends State<PersonalPageScreen> {
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String avatarUrl = "https://www.example.com/avatar.jpg"; // Ảnh mặc định
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    print("Token hiện tại: $token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập!")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8088/api/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X_token": globalFcmToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final results = data["results"]; // Lấy phần dữ liệu bên trong "results"
        setState(() {
          firstName = results["firstName"] ?? "";
          lastName = results["lastName"] ?? "";
          email = results["email"] ?? "";
          phone = results["phoneNumber"] ?? ""; // Sử dụng key "phoneNumber"
          avatarUrl = results["profileImg"] != null && results["profileImg"] is String
              ? results["profileImg"]
              : "https://www.example.com/avatar.jpg"; // Ảnh mặc định
          // Sử dụng key "profileImg"
          isLoading = false;
          print("Avatar URL: $avatarUrl");

        });


    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi lấy dữ liệu: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Hồ sơ cá nhân",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.blueAccent),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Container(color: Colors.white),
          Center(
            child: SingleChildScrollView(
              child: GlassmorphicContainer(
                width: 350,
                height: 400,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Animate(
                      effects: [FadeEffect(duration: 800.ms), ScaleEffect()],
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child:CircleAvatar(
                          radius: 50,
                          backgroundImage: avatarUrl.startsWith("data:image")
                              ? MemoryImage(base64Decode(avatarUrl.split(',')[1]))
                              : NetworkImage(avatarUrl) as ImageProvider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "$firstName $lastName",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Email: $email",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Số điện thoại: $phone",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),
                    Animate(
                      effects: [SlideEffect(duration: 600.ms)],
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          shadowColor: Colors.black45,
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        child: Text(
                          "Chỉnh sửa hồ sơ",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
