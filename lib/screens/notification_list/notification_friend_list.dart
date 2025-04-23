import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationFriendListScreen extends StatefulWidget {
  const NotificationFriendListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationFriendListScreen> createState() => _NotificationFriendListScreenState();
}

class _NotificationFriendListScreenState extends State<NotificationFriendListScreen> {
  final Set<String> _selectedFriendIds = {};
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;

  late final int sosAlertId;
  late final String message;
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['sosAlertId'] == null) {
        _showDialog('Không tìm thấy sosAlertId. Vui lòng thử lại.');
        return;
      }
      final raw = args['sosAlertId'];
      sosAlertId = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
      message = args['message'] ?? '';
      _argsLoaded = true;
    }
  }

  Future<void> fetchFriends() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showDialog('Không tìm thấy token.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final resp = await http.get(
        Uri.parse('http://10.0.2.2:8088/api/friends/list'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (resp.statusCode == 200) {
        final list = jsonDecode(utf8.decode(resp.bodyBytes));
        final data = (list is List) ? list : list['results'] ?? [];
        _friends = (data as List).map((e) {
          final p = e['profileResponse'];
          return {
            'id': e['friendRelationshipId'].toString(),
            'name': '${p['firstName']} ${p['lastName']}',
          };
        }).toList();
      } else {
        _showDialog('Lỗi tải bạn bè: ${resp.statusCode}');
      }
    } catch (e) {
      _showDialog('Lỗi kết nối: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chọn bạn bè', style: GoogleFonts.poppins(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📨 Nội dung tín hiệu:', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(message, style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 16),
            Expanded(
              child: _friends.isEmpty
                  ? Center(child: Text('Bạn chưa có bạn bè.', style: GoogleFonts.poppins()))
                  : ListView.separated(
                itemCount: _friends.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildFriendTile(_friends[index]),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedFriendIds.isEmpty ? null : _submitSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  'Gửi tín hiệu',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
    final id = friend['id'] as String;
    final selected = _selectedFriendIds.contains(id);

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (selected) _selectedFriendIds.remove(id);
            else _selectedFriendIds.add(id);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? Colors.blueAccent : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true) _selectedFriendIds.add(id);
                    else _selectedFriendIds.remove(id);
                  });
                },
                activeColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(friend['name'], style: GoogleFonts.poppins(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _submitSelection() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showDialog('Không tìm thấy token.');
      setState(() => _isLoading = false);
      return;
    }

    final friendIds = _selectedFriendIds.map(int.tryParse).whereType<int>().toList();
    debugPrint('POST personal_sos_alerts {sosAlertId: $sosAlertId, friendIds: $friendIds}');

    try {
      final resp = await http.post(
        Uri.parse('http://10.0.2.2:8088/api/personal_sos_alerts'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'sosAlertId': sosAlertId, 'friendIds': friendIds}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _showDialog('✅ Đã gửi đến ${friendIds.length} bạn.');
      } else {
        _showDialog('❌ Lỗi ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      _showDialog('Lỗi kết nối: $e');
    }

    setState(() => _isLoading = false);
  }

  void _showDialog(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Thông báo', style: GoogleFonts.poppins(color: Colors.blueAccent)),
      content: Text(msg, style: GoogleFonts.poppins()),
      actions: [ TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Đóng', style: GoogleFonts.poppins(color: Colors.blueAccent))) ],
    ));
  }
}
