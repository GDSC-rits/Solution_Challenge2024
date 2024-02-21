import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  Position currentPosition = Position(
      latitude: 43.0686606, // 初期値として北海道の座標を設定
      longitude: 141.3485613,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0,
      headingAccuracy: 0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _updateCameraPosition();
    }
  }

  void _updateCameraPosition() {
    if (_controller != null) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 14.0,
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _updateCameraPosition();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 4つ以上のアイテムを持つために必要
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bigpin_red.png',
              width: 24, // アイコンのサイズを指定
              height: 24,
            ),
            label: 'food',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bigpin_blue.png',
              width: 24, // アイコンのサイズを指定
              height: 24,
            ),
            label: 'bathroom',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bigpin_yellow.png',
              width: 24, // アイコンのサイズを指定
              height: 24,
            ),
            label: 'dangerous',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/bigpin_green.png',
              width: 24, // アイコンのサイズを指定
              height: 24,
            ),
            label: 'shelter',
          ),
        ],
        onTap: (index) {
          if (currentPosition != null) {
            String pinColor;
            switch (index) {
              case 0:
                pinColor = "red";
                break;
              case 1:
                pinColor = "blue";
                break;
              case 2:
                pinColor = "yellow";
                break;
              case 3:
                pinColor = "green";
                break;
              default:
                pinColor = "red"; // デフォルトの色
            }
            _setCustomMarker(pinColor);
          }
        },
      ),
    );
  }

  Future<void> _setCustomMarker(String pinColor) async {
    // 現在位置を取得
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // アセットから画像を読み込む
    final String assetPath = 'assets/bigpin_$pinColor.png'; // 色に基づいたアセットパス
    final ByteData byteData = await rootBundle.load(assetPath);
    final Uint8List imageBytes = byteData.buffer.asUint8List();

    // 画像からBitmapDescriptorを作成
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIconBytes =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    final BitmapDescriptor customIcon =
        BitmapDescriptor.fromBytes(markerIconBytes);

    // マーカーIDをユニークにする
    String markerIdVal = 'marker_id_${_markers.length}';
    MarkerId markerId = MarkerId(markerIdVal);

    // マーカーを作成
    final marker = Marker(
      markerId: markerId,
      position: LatLng(currentPosition.latitude, currentPosition.longitude),
      icon: customIcon,
      anchor: Offset(0.5, 1.0), // アイコンの底中央が座標に固定される
    );

    setState(() {
      // _markersセットに新しいマーカーを追加
      _markers.add(marker);
    });
  }

  @override
  void dispose() {
    //positionStream.cancel();
    super.dispose();
  }
}
