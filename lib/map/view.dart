import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location.dart';

class MapViewWidget extends StatelessWidget {
  final Marker marker;
  final Circle? circle;

  const MapViewWidget({super.key, required this.marker, this.circle});

  @override
  Widget build(BuildContext context) {
    return LocationBuilder(
      builder: (context, location) {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 13.0,
          ),
          myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
          myLocationEnabled: true, // 현재 위치 표시 활성화
          markers: <Marker>{marker},
          circles: <Circle>{_createCircle(location)},
        );
      },
    );
  }

  Circle _createCircle(LatLng location) {
    return Circle(
      circleId: CircleId('currentLocation'),
      center: location,
      radius: 200,
      fillColor: Colors.yellow.withAlpha(76),
      strokeColor: Colors.orange,
      strokeWidth: 2,
    );
  }

}