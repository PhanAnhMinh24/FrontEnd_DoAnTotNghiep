import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _avatarImage;
  String _base64Image = "";

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _firstNameController.text = prefs.getString("firstName") ?? "";
    _lastNameController.text = prefs.getString("lastName") ?? "";
    _phoneController.text = prefs.getString("phoneNumber") ?? "";
    _base64Image = prefs.getString("profileImg") ?? ""; // Tránh null

    String? token = prefs.getString("token");
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse("http://10.0.2.2:8088/api/profile"),
          headers: {"Authorization": "Bearer $token"},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String profileImg = data["profileImg"] ?? ""; // Tránh null

          if (profileImg.isNotEmpty) {
            setState(() {
              _base64Image = profileImg;
              _avatarImage = null;
            });
          }
        }
      } catch (e) {
        print("Lỗi tải ảnh: $e");
      }
    }
  }



  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      setState(() {
        _avatarImage = imageFile;
        _base64Image = "data:image/png;base64,$base64String";
      });
      print("Ảnh đã chọn: $_avatarImage");
      print("Chuỗi Base64: $_base64Image");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera, color: Colors.blueAccent),
                title: const Text("Chụp ảnh"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blueAccent),
                title: const Text("Chọn từ thư viện"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập!")),
      );
      return;
    }

    final Map<String, dynamic> body = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "phoneNumber": _phoneController.text,
      "profileImg": (_base64Image != null && _base64Image!.isNotEmpty) ? _base64Image : null,
    };


    try {
      final response = await http.put(
        Uri.parse("http://10.0.2.2:8088/api/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật hồ sơ thành công!")),
        );
        await prefs.setString("firstName", _firstNameController.text);
        await prefs.setString("lastName", _lastNameController.text);
        await prefs.setString("phoneNumber", _phoneController.text);
        await prefs.setString("profileImg", _base64Image);

        setState(() {});
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cập nhật thất bại: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền màn hình trắng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            "Chỉnh sửa hồ sơ",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Align(
            alignment: Alignment.center,
            child: Card(
              color: Colors.white,
              elevation: 5,
              shadowColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Giữ nội dung đúng kích thước
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _base64Image.isNotEmpty && _base64Image.startsWith("data:image")
                                  ? MemoryImage(base64Decode(_base64Image.split(',')[1]))
                                  : (_avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : const AssetImage("assets/images/avatar_placeholder.png")) as ImageProvider,

                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Họ", Icons.person, _firstNameController),
                    const SizedBox(height: 15),
                    _buildTextField("Tên", Icons.person_outline, _lastNameController),
                    const SizedBox(height: 15),
                    _buildTextField("Số điện thoại", Icons.phone, _phoneController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, // Cho nút dài full chiều ngang
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blueAccent.withOpacity(0.4),
                        ),
                        child: Text(
                          "Lưu thay đổi",
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
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
