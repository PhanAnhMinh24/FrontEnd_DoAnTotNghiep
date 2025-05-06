import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:doantotnghiep/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:doantotnghiep/screens/personal_page/personal_page_screen.dart';
import 'package:doantotnghiep/screens/friends/friends_list_screen.dart';
import 'package:doantotnghiep/screens/signal/signal_creation_screen.dart';
import 'package:doantotnghiep/screens/signal/list_sos_screen.dart';
import 'package:doantotnghiep/screens/map/map_screen.dart';

class CupertinoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLogoutPressed;

  const CupertinoAppBar({
    super.key,
    this.onNotificationPressed,
    this.onLogoutPressed,
  });

  @override
  _CupertinoAppBarState createState() => _CupertinoAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _CupertinoAppBarState extends State<CupertinoAppBar> {
  String _userName = "Người dùng";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString("firstName") ?? "";
    String lastName = prefs.getString("lastName") ?? "";

    // Giải mã dữ liệu tránh lỗi ký tự đặc biệt
    firstName = utf8.decode(utf8.encode(firstName));
    lastName = utf8.decode(utf8.encode(lastName));

    setState(() {
      _userName = "$firstName $lastName".trim().replaceAll(RegExp(r'\s+'), ' ');
    });

    print("Tên hiển thị: $_userName"); // Kiểm tra log
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CupertinoNavigationBar(
        backgroundColor: Colors.white, // AppBar nền trắng
        middle: Text(
          "Chào, $_userName!",
          style: const TextStyle(color: Colors.blueAccent, fontSize: 18),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(LucideIcons.menu, color: Colors.blueAccent, size: 26),
          onPressed: () => _showMenuOptions(context),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationButton(context),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  void _showMenuOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Hiệu ứng kính mờ
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.person, color: CupertinoColors.activeBlue),
                    title: const Text("Hồ sơ cá nhân"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => PersonalPageScreen()),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.group, color: CupertinoColors.activeBlue),
                    title: const Text("Danh sách bạn bè"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => FriendsListScreen()),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(LucideIcons.alertTriangle, color: CupertinoColors.activeBlue),
                    title: const Text("Tạo tín hiệu"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => SignalCreationScreen()),
                      );
                    },
                  ),
                  // Mục Danh sách tín hiệu đã tạo
                  CupertinoListTile(
                    leading: const Icon(LucideIcons.listEnd, color: CupertinoColors.activeBlue),
                    title: const Text("Danh sách tín hiệu đã tạo"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => CreatedSignalsListScreen()),
                      );
                    },
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.map, color: CupertinoColors.activeBlue),
                    title: const Text("Xem bản đồ"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => const MapScreen()),
                      );
                    },
                  ),
                  const Divider(), // Đường kẻ ngăn cách
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.clear, color: CupertinoColors.destructiveRed),
                    title: const Text("Đóng", style: TextStyle(color: CupertinoColors.destructiveRed)),
                    onTap: () => Navigator.pop(context),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// **Nút thông báo**
  Widget _buildNotificationButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Icon(LucideIcons.bell, color: Colors.blueAccent, size: 26),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      onPressed: widget.onNotificationPressed ?? () {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Thông báo"),
            content: const Text("Bạn có thông báo mới!"),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("Đóng"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// **Nút đăng xuất**
  Widget _buildLogoutButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: const Icon(LucideIcons.logOut, color: Colors.blueAccent, size: 26),
      onPressed: widget.onLogoutPressed ?? () {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Đăng xuất"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text("Đăng xuất"),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); // Xóa dữ liệu đăng nhập
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
