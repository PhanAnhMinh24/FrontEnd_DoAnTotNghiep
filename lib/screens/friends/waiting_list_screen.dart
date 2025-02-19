import 'package:flutter/material.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  // Cập nhật dữ liệu với thời gian gửi lời mời
  final List<Map<String, dynamic>> _friendRequests = [
    {'name': 'Nguyễn Văn A', 'timeSent': '10:30 AM'},
    {'name': 'Trần Thị B', 'timeSent': '2:15 PM'},
    {'name': 'Lê Minh C', 'timeSent': '4:45 PM'},
  ];

  void _acceptRequest(String name) {
    setState(() {
      // Chấp nhận lời mời kết bạn
      _friendRequests.removeWhere((request) => request['name'] == name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chấp nhận lời mời kết bạn của $name')),
    );
  }

  void _rejectRequest(String name) {
    setState(() {
      // Từ chối lời mời kết bạn
      _friendRequests.removeWhere((request) => request['name'] == name);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã từ chối lời mời kết bạn của $name')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách lời mời kết bạn'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _friendRequests.isEmpty
          ? Center(child: Text('Không có lời mời kết bạn nào.'))
          : ListView(
        children: _friendRequests.map((request) {
          return ListTile(
            title: Text(request['name']!),
            subtitle: Text('Lời mời gửi lúc: ${request['timeSent']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptRequest(request['name']),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => _rejectRequest(request['name']),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
