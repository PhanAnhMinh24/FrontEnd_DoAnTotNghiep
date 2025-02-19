import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SidebarScreen extends StatefulWidget {
  const SidebarScreen({super.key});

  @override
  _SidebarScreenState createState() => _SidebarScreenState();
}

class _SidebarScreenState extends State<SidebarScreen> {
  bool isCollapsed = true;
  final String userName = "Phan Anh Minh"; // Thay bằng tên user thực tế

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey[200]), // Nền chính
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCollapsed ? 70 : 250,
            decoration: BoxDecoration(
              color: Colors.white, // Nền sidebar màu trắng
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                    });
                  },
                ).animate().scale(duration: 200.ms), // Animation for menu button

                if (!isCollapsed) // Chỉ hiển thị lời chào khi sidebar mở rộng
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Text(
                      "Chào, $userName 👋",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ).animate().fade(duration: 300.ms), // Fade animation for greeting
                  ),

                const SizedBox(height: 10),
                // Add an animation for menu items appearing one by one
                Column(
                  children: menuItems
                      .asMap()
                      .map((index, item) {
                    return MapEntry(
                      index,
                      buildMenuItem(item, index),
                    );
                  })
                      .values
                      .toList(),
                ),
              ],
            ),
          ).animate().fade(duration: 300.ms), // Fade in the sidebar itself
        ],
      ),
    );
  }

  Widget buildMenuItem(MenuItem item, int index) {
    return MouseRegion(
      onEnter: (_) => setState(() => item.isHovered = true),
      onExit: (_) => setState(() => item.isHovered = false),
      child: ListTile(
        leading: Icon(item.icon, color: Colors.blueAccent),
        title: isCollapsed
            ? null
            : Text(
          item.title,
          style: TextStyle(
            color: item.isHovered
                ? Colors.blueAccent.shade700
                : Colors.blueAccent,
            fontWeight: item.isHovered
                ? FontWeight.bold
                : FontWeight.w500,
          ),
        ).animate().fade(duration: 300.ms).slideX(duration: 400.ms, curve: Curves.easeInOut),
        onTap: () {
          if (item.title == 'Thông báo') {
            // Điều hướng đến màn hình "Thông báo"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsScreen()),
            );
          } else if (item.title == 'Trang cá nhân') {
            // Điều hướng đến trang cá nhân
          } else if (item.title == 'Cài đặt') {
            // Điều hướng đến trang cài đặt
          } else if (item.title == 'Danh sách bạn bè') {
            // Điều hướng đến danh sách bạn bè
          } else if (item.title == 'Đăng xuất') {
            // Xử lý đăng xuất
          }
        },
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  bool isHovered;
  MenuItem(this.title, this.icon, {this.isHovered = false});
}

final List<MenuItem> menuItems = [
  MenuItem('Thông báo', Icons.notifications),
  MenuItem('Trang cá nhân', Icons.person),
  MenuItem('Danh sách bạn bè', Icons.group),
  MenuItem('Cài đặt', Icons.settings),  MenuItem('Đăng xuất', Icons.exit_to_app),
];

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: List.generate(10, (index) {
          return ListTile(
            leading: Icon(Icons.notifications, color: Colors.blueAccent),
            title: Text('Thông báo $index', style: TextStyle(fontSize: 16)),
            subtitle: Text('Đây là nội dung của thông báo $index'),
            onTap: () {
              // Mở chi tiết thông báo (có thể thêm chi tiết nếu cần)
            },
          );
        }),
      ),
    );
  }
}
