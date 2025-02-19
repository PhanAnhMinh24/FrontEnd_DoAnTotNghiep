import 'package:flutter/material.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final List<Map<String, dynamic>> _friendsList = [
    {'name': 'Nguyễn Văn A', 'isOnline': true, 'isPending': false},
    {'name': 'Trần Thị B', 'isOnline': false, 'isPending': false},
    {'name': 'Lê Minh C', 'isOnline': true, 'isPending': false},
    {'name': 'Phan Anh Minh', 'isOnline': false, 'isPending': false},
  ];

  final List<Map<String, dynamic>> _pendingFriendsList = []; // Danh sách bạn bè đang chờ xác nhận

  List<Map<String, dynamic>> _filteredFriendsList = [];
  List<Map<String, dynamic>> _filteredPendingFriendsList = []; // Lọc danh sách bạn bè đang chờ

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFriendsList = _friendsList;
    _filteredPendingFriendsList = _pendingFriendsList;
    _searchController.addListener(_filterFriends);
  }

  void _filterFriends() {
    setState(() {
      _filteredFriendsList = _friendsList
          .where((friend) =>
          friend['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
      _filteredPendingFriendsList = _pendingFriendsList
          .where((friend) =>
          friend['name']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  bool _isValidName(String name) {
    final regExp = RegExp(r'^[a-zA-Z0-9\s]+$');
    return name.isNotEmpty && regExp.hasMatch(name);
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        return AlertDialog(
          title: const Text("Thêm bạn bè"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newName = value;
                },
                decoration: const InputDecoration(hintText: "Nhập tên bạn bè"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty && _isValidName(newName)) {
                  setState(() {
                    // Thêm bạn bè vào danh sách đang chờ xác nhận
                    _pendingFriendsList.add({'name': newName, 'isOnline': false, 'isPending': true});
                    _filterFriends(); // Cập nhật lại danh sách hiển thị
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tên không hợp lệ. Không được để trống và không chứa ký tự đặc biệt.')),
                  );
                }
              },
              child: const Text("Thêm"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Hủy"),
            ),
          ],
        );
      },
    );
  }

  void _acceptFriendRequest(String name) {
    setState(() {
      // Chuyển bạn bè từ danh sách chờ sang danh sách bạn bè
      var friend = _pendingFriendsList.firstWhere((f) => f['name'] == name);
      _friendsList.add({'name': name, 'isOnline': false, 'isPending': false});
      _pendingFriendsList.remove(friend);
      _filterFriends(); // Cập nhật lại danh sách hiển thị
    });
  }

  void _rejectFriendRequest(String name) {
    setState(() {
      // Xóa bạn bè từ danh sách chờ
      _pendingFriendsList.removeWhere((f) => f['name'] == name);
      _filterFriends(); // Cập nhật lại danh sách hiển thị
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách bạn bè"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFriend, // Mở màn hình thêm bạn bè
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm bạn bè',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (_filteredPendingFriendsList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Bạn bè đang chờ xác nhận', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ..._filteredPendingFriendsList.map((friend) {
                  return ListTile(
                    title: Text(friend['name']!),
                    subtitle: const Text('Đang chờ xác nhận'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _acceptFriendRequest(friend['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () => _rejectFriendRequest(friend['name']),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                if (_filteredFriendsList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Danh sách bạn bè', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ..._filteredFriendsList.map((friend) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        friend['name']![0],
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    title: Text(friend['name']!),
                    subtitle: Text(friend['isOnline'] ? 'Online' : 'Offline'),
                    trailing: Icon(
                      friend['isOnline'] ? Icons.circle : Icons.circle_outlined,
                      color: friend['isOnline'] ? Colors.green : Colors.red,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
