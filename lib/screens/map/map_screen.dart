import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  VietmapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ GPS có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied');
      }
    }

    // Lấy vị trí hiện tại của người dùng
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Bản đồ"),
      ),
      child: SafeArea(
        child: _currentLocation == null
            ? const Center(child: CircularProgressIndicator())
            : VietmapGL(
          styleString:
          'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=42ec7719c83d28f2036ebe8f133bb032662e3dbfa897504a',
          initialCameraPosition: CameraPosition(
            target: _currentLocation!,
            zoom: 14,
          ),
          onMapCreated: (VietmapController controller) {
            setState(() {
              _mapController = controller;
            });
          },
        ),
      ),
    );
  }
}
