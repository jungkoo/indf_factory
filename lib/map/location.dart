
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../initialize.dart';

typedef LocationWithBuilder = Widget Function(BuildContext context, LatLng location);

class LocationBuilder extends StatelessWidget {
  final LocationWithBuilder builder;

  const LocationBuilder({super.key, required this.builder});

  /*
   * 위치 권한을 요청하고 위치를 가져오는 위젯
   * builder 에서 위치를 사용하여 위젯을 그린다
   */
  @override
  Widget build(BuildContext context) => FutureBuilder<LatLng>(
      // 현재 위치를 가져 온다
      future: LocationInstance().currentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        } else if (snapshot.hasError) {
          return Center(child: Text("위치 권한 없음"));
        } else {
          return Center(child: Text("xml 설정에 권한과 API 키추가 필요"));
        }
      }
    );
}