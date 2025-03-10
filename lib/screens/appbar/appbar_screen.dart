import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:doantotnghiep/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CupertinoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onLogoutPressed;

  const CupertinoAppBar({
    super.key,
    this.onMenuPressed,
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
        color: CupertinoColors.systemBlue,
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
        backgroundColor: CupertinoColors.systemBlue.withOpacity(0.95),
        middle: Text(
          "Chào, $_userName!",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bars, color: Colors.white, size: 26),
          onPressed: widget.onMenuPressed,
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

  /// **Nút thông báo**
  Widget _buildNotificationButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Icon(CupertinoIcons.bell, color: Colors.white, size: 26),
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
      child: const Icon(LucideIcons.logOut, color: Colors.white, size: 26),
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
