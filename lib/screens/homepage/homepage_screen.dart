import 'package:flutter/material.dart';
import 'package:doantotnghiep/screens/appbar/appbar_screen.dart'; // Import AppBar
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CupertinoAppBar(), // Thêm AppBar

          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white, // Đặt nền trắng
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dòng chữ chính với hiệu ứng shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.blueAccent,
                      highlightColor: Colors.lightBlueAccent,
                      child: const Text(
                        "Gia đình an toàn – Bạn an tâm!",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate()
                        .fade(duration: 800.ms)
                        .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 15),

                    // Slogan phụ để tăng tính thuyết phục
                    const Text(
                      "Bảo vệ những người thân yêu của bạn mọi lúc, mọi nơi.",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fade(duration: 1000.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
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
