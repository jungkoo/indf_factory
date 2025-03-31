
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef LocationWithBuilder = Widget Function(BuildContext context, LatLng location);

class LocationBuilder extends StatelessWidget {
  final LocationWithBuilder builder;
  final LatLng? _defaultValue;

  const LocationBuilder({super.key, required this.builder, LatLng? defaultValue}) : _defaultValue = defaultValue;


  @override
  Widget build(BuildContext context) {
    final defaultLocation = _defaultValue ??  const LatLng(37.4200, 127.1265);
    return FutureBuilder<LatLng>(
      // 현재 위치를 가져 온다
      future: _getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint('Error: 현재 위치를 가져오는 중 오류가 발생했습니다 ${snapshot.error}');
          return Center(
                child: Text("위치 권한을 가져오지 못했습니다"),
          );
        } else if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        } else {
          return builder(context, defaultLocation);
        }
      }
    );
  }

  Future<LatLng> _getCurrentLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      final currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return LatLng(currentPosition.latitude, currentPosition.longitude);
    } else {
      // 사용자 권한 요청
      final requestPermission = await Geolocator.requestPermission();
      if (requestPermission == LocationPermission.always || requestPermission == LocationPermission.whileInUse) {
        final currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        return LatLng(currentPosition.latitude, currentPosition.longitude);
      } else {
        debugPrint("위치 권한이 거부됨: $requestPermission");
      }
      return _defaultValue ?? const LatLng(37.4200, 127.1265);
    }
  }
}