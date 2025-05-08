
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  VietmapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Bản đồ"),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            VietmapGL(
              myLocationEnabled: true,
              trackCameraPosition: true,
              styleString:
              'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=42ec7719c83d28f2036ebe8f133bb032662e3dbfa897504a',
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.759, 109.218),
                zoom: 14,
              ),
              onMapCreated: (VietmapController controller) {
                setState(() {
                  _mapController = controller;
                });
              },
            ),
            if (_mapController != null)
              MarkerLayer(
                markers: [
                  Marker(
                    alignment: Alignment.topCenter,
                    width: 100,
                    height: 70,
                    latLng: LatLng(13.759, 109.218),
                    child: Column(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Text(
                            'Người thân của bạn đang ở đây',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.location_on,
                            color: Colors.blueAccent, size: 50),
                      ],
                    ),
                  )
                ],
                mapController: _mapController!,
              ),
          ],
        ),
      ),
    );
  }
}
