import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  final List<Map<String, dynamic>> _friendsList = [];
  final List<Map<String, dynamic>> _pendingFriendsList = [];
  final List<Map<String, dynamic>> _sentFriendRequests = [];

  List<Map<String, dynamic>> _filteredFriendsList = [];
  List<Map<String, dynamic>> _filteredPendingFriendsList = [];
  List<Map<String, dynamic>> _filteredSentFriendRequests = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterFriends);
    _refreshData();
  }

  Future<void> _refreshData() async {
    await fetchFriends();
    await fetchSentFriendRequests();
    await fetchPendingFriendRequests();
  }

  Future<void> fetchFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackBar("Bạn chưa đăng nhập!");
      return;
    }
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8088/api/friends/list"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> data;
        if (jsonData is List) {
          data = jsonData;
        } else if (jsonData is Map) {
          data = jsonData.containsKey("results") && jsonData["results"] is List
              ? jsonData["results"]
              : [jsonData];
        } else {
          data = [];
        }
        List<Map<String, dynamic>> friends = data.map((item) {
          final profile = item['profileResponse'];
          return {
            'id': profile['id'],
            'name': "${profile['firstName']} ${profile['lastName']}",
            'base64Image': profile['profileImg'] ?? "",
            'isPending': false,
          };
        }).toList();
        setState(() {
          _friendsList
            ..clear()
            ..addAll(friends);
          _filteredFriendsList = _filterList(_friendsList);
        });
      } else {
        print("Lỗi lấy danh sách bạn bè: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
  }

  Future<void> fetchSentFriendRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackBar("Bạn chưa đăng nhập!");
      return;
    }
    try {
      final url = Uri.parse("http://10.0.2.2:8088/api/friends/sent");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = jsonData["results"] ?? [];
        setState(() {
          _sentFriendRequests.clear();
          _sentFriendRequests.addAll(results.map((result) {
            final profile = result['profileResponse'];
            return {
              'friendRelationshipId': result['friendRelationshipId'],
              'name': "${profile['firstName']} ${profile['lastName']}",
              'base64Image': profile['profileImg'] ?? "",
              'email': profile['email'] ?? "",
              'phoneNumber': profile['phoneNumber'] ?? "",
              'isPending': true,
            };
          }).toList());
          _filteredSentFriendRequests = _filterList(_sentFriendRequests);
        });
      } else {
        print("Lỗi khi lấy danh sách lời mời đã gửi: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối khi lấy lời mời đã gửi: $e");
    }
  }

  Future<void> fetchPendingFriendRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackBar("Bạn chưa đăng nhập!");
      return;
    }
    try {
      final url = Uri.parse("http://10.0.2.2:8088/api/friends/pending");
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> results = jsonData["results"] ?? [];
        setState(() {
          _pendingFriendsList.clear();
          _pendingFriendsList.addAll(results.map((result) {
            final profile = result['profileResponse'];
            return {
              'friendRelationshipId': result['friendRelationshipId'],
              'id': profile['id'],
              'name': "${profile['firstName']} ${profile['lastName']}",
              'base64Image': profile['profileImg'] ?? "",
              'email': profile['email'] ?? "",
              'phoneNumber': profile['phoneNumber'] ?? "",
            };
          }).toList());
          _filteredPendingFriendsList = _filterList(_pendingFriendsList);
        });
      } else {
        print("Lỗi khi lấy danh sách lời mời đến: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối khi lấy lời mời đến: $e");
    }
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> list) {
    return list.where((friend) => friend['name']
        .toLowerCase()
        .contains(_searchController.text.toLowerCase())).toList();
  }

  void _filterFriends() {
    setState(() {
      _filteredFriendsList = _filterList(_friendsList);
      _filteredPendingFriendsList = _filterList(_pendingFriendsList);
      _filteredSentFriendRequests = _filterList(_sentFriendRequests);
    });
  }

  bool _isValidName(String name) {
    final regExp = RegExp(r'^[a-zA-Z0-9\s@._-]+$');
    return name.isNotEmpty && regExp.hasMatch(name);
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        return AlertDialog(
          title: const Text("Thêm bạn bè"),
          content: TextField(
            onChanged: (value) => newName = value,
            decoration: const InputDecoration(hintText: "Nhập email hoặc sđt"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty && _isValidName(newName)) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? token = prefs.getString("token");
                  if (token == null) {
                    _showSnackBar("Bạn chưa đăng nhập!");
                    return;
                  }
                  try {
                    final searchUrl =
                    Uri.parse("http://10.0.2.2:8088/api/friends/search");
                    final searchBody = jsonEncode({"keyword": newName});
                    final searchResponse = await http.post(
                      searchUrl,
                      headers: {
                        "Authorization": "Bearer $token",
                        "Content-Type": "application/json",
                      },
                      body: searchBody,
                    );
                    if (searchResponse.statusCode == 200) {
                      var jsonData =
                      jsonDecode(utf8.decode(searchResponse.bodyBytes));
                      List<dynamic> results = jsonData["results"] ?? [];
                      if (results.isNotEmpty) {
                        Navigator.of(context).pop(); // Đóng dialog tìm kiếm ban đầu
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Chọn bạn để gửi lời mời"),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: 300,
                                child: ListView.builder(
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final friend = results[index];
                                    String friendName =
                                        "${friend['firstName']} ${friend['lastName']}";
                                    return ListTile(
                                      leading: friend['profileImg'] != null &&
                                          friend['profileImg']
                                              .toString()
                                              .isNotEmpty
                                          ? CircleAvatar(
                                        backgroundImage: friend['profileImg']
                                            .toString()
                                            .startsWith("data:image")
                                            ? MemoryImage(base64Decode(friend['profileImg']
                                            .toString()
                                            .split(',')[1]))
                                            : NetworkImage(friend['profileImg'])
                                        as ImageProvider,
                                      )
                                          : CircleAvatar(child: Text(friendName.isNotEmpty ? friendName[0] : "")),
                                      title: Text(friendName),
                                      subtitle: Text("Email: ${friend['email']}\nSĐT: ${friend['phoneNumber']}"),
                                      onTap: () async {
                                        try {
                                          final addUrl = Uri.parse("http://10.0.2.2:8088/api/friends");
                                          final addBody = jsonEncode({"friendId": friend['id']});
                                          final addResponse = await http.post(
                                            addUrl,
                                            headers: {
                                              "Authorization": "Bearer $token",
                                              "Content-Type": "application/json",
                                            },
                                            body: addBody,
                                          );
                                          if (addResponse.statusCode == 200) {
                                            Navigator.of(context).pop();
                                            _showSnackBar("Lời mời kết bạn đã được gửi.");
                                            _refreshData();
                                          } else {
                                            Navigator.of(context).pop();
                                            _showSnackBar("Lỗi khi gửi lời mời kết bạn.");
                                          }
                                        } catch (e) {
                                          Navigator.of(context).pop();
                                          _showSnackBar("Lỗi kết nối tới máy chủ.");
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("Hủy"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        _showSnackBar("Không tìm thấy bạn.");
                      }
                    } else {
                      _showSnackBar("Lỗi khi gửi yêu cầu.");
                    }
                  } catch (e) {
                    print("Lỗi khi gọi API: $e");
                    _showSnackBar("Lỗi kết nối tới máy chủ.");
                  }
                } else {
                  _showSnackBar('Tên không hợp lệ. Không được để trống và không chứa ký tự đặc biệt.');
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

  Future<void> _confirmFriendRequest(int friendId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackBar("Bạn chưa đăng nhập!");
      return;
    }
    try {
      final url = Uri.parse("http://10.0.2.2:8088/api/friends/confirm");
      final body = jsonEncode({"friendId": friendId, "status": status});
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );
      if (response.statusCode == 200) {
        _showSnackBar("Yêu cầu đã được ${status == "accepted" ? "chấp nhận" : "từ chối"}.");
        _refreshData();
      } else {
        _showSnackBar("Lỗi khi xử lý yêu cầu.");
      }
    } catch (e) {
      print("Lỗi khi gọi API confirm: $e");
      _showSnackBar("Lỗi kết nối tới máy chủ.");
    }
  }

  void _cancelSentFriendRequest(String name) {
    setState(() {
      _sentFriendRequests.removeWhere((f) => f['name'] == name);
      _filteredSentFriendRequests = _filterList(_sentFriendRequests);
    });
    _refreshData();
  }

  Future<void> _deleteFriend(int friendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      _showSnackBar("Bạn chưa đăng nhập!");
      return;
    }
    try {
      final url = Uri.parse("http://10.0.2.2:8088/api/friends/$friendId");
      final body = jsonEncode({"friendId": friendId});
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );
      if (response.statusCode == 200) {
        _showSnackBar("Bạn đã xóa bạn bè thành công.");
        _refreshData();
      } else {
        print("Lỗi khi xóa bạn bè: ${response.statusCode} ${response.body}");
        _showSnackBar("Lỗi khi xóa bạn bè.");
      }
    } catch (e) {
      print("Lỗi khi gọi API xóa bạn bè: $e");
      _showSnackBar("Lỗi kết nối tới máy chủ.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildPendingFriends() {
    if (_filteredPendingFriendsList.isEmpty) {
      return const Center(child: Text("Không có yêu cầu chờ xác nhận."));
    }
    return ListView.builder(
      itemCount: _filteredPendingFriendsList.length,
      itemBuilder: (context, index) {
        final friend = _filteredPendingFriendsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: friend['base64Image'].isNotEmpty
                ? CircleAvatar(
              backgroundImage: friend['base64Image'].toString().startsWith("data:image")
                  ? MemoryImage(base64Decode(friend['base64Image'].toString().split(',')[1]))
                  : NetworkImage(friend['base64Image']) as ImageProvider,
            )
                : CircleAvatar(child: Text(friend['name'][0])),
            title: Text(friend['name']),
            subtitle: Text("Email: ${friend['email']}\nSĐT: ${friend['phoneNumber']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _confirmFriendRequest(friend['id'], "accepted"),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => _confirmFriendRequest(friend['id'], "rejected"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentFriendRequests() {
    if (_filteredSentFriendRequests.isEmpty) {
      return const Center(child: Text("Bạn chưa gửi lời mời kết bạn nào."));
    }
    return ListView.builder(
      itemCount: _filteredSentFriendRequests.length,
      itemBuilder: (context, index) {
        final friend = _filteredSentFriendRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: friend['base64Image'].isNotEmpty
                ? CircleAvatar(
              backgroundImage: friend['base64Image'].toString().startsWith("data:image")
                  ? MemoryImage(base64Decode(friend['base64Image'].toString().split(',')[1]))
                  : NetworkImage(friend['base64Image']) as ImageProvider,
            )
                : CircleAvatar(child: Text(friend['name'][0])),
            title: Text(friend['name']),
            subtitle: Text("Email: ${friend['email']}\nSĐT: ${friend['phoneNumber']}"),
            trailing: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _cancelSentFriendRequest(friend['name']),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendsList() {
    if (_filteredFriendsList.isEmpty) {
      return const Center(child: Text("Bạn chưa có bạn bè."));
    }
    return ListView.builder(
      itemCount: _filteredFriendsList.length,
      itemBuilder: (context, index) {
        final friend = _filteredFriendsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              backgroundImage: friend['base64Image'].isNotEmpty
                  ? (friend['base64Image'].startsWith("data:image")
                  ? MemoryImage(base64Decode(friend['base64Image'].split(',')[1]))
                  : NetworkImage(friend['base64Image']) as ImageProvider)
                  : null,
              child: friend['base64Image'].isEmpty
                  ? Text(friend['name'][0], style: const TextStyle(color: Colors.white, fontSize: 20))
                  : null,
            ),
            title: Text(friend['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.blueAccent),
              onPressed: () => _deleteFriend(friend['id']),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Danh sách bạn bè",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.blueAccent),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.blueAccent),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addFriend,
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đã gửi lời mời'),
              Tab(text: 'Bạn bè'),
            ],
          ),
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
              child: TabBarView(
                children: [
                  _buildPendingFriends(),
                  _buildSentFriendRequests(),
                  _buildFriendsList(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addFriend,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
