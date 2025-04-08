import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location.dart';

class LocationViewWidget extends StatelessWidget {
  final Marker marker;
  final Circle? circle;
  final double zoom;
  final bool myLocationButtonEnabled;
  final bool myLocationEnabled;

  const LocationViewWidget({
    super.key,
    required this.marker,
    this.circle,
    this.zoom=13.0,
    this.myLocationButtonEnabled=true,
    this.myLocationEnabled=true
  });

  @override
  Widget build(BuildContext context) {
    return LocationBuilder(
      builder: (context, location) {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: zoom,
          ),
          myLocationButtonEnabled: myLocationButtonEnabled, // 현재 위치 버튼 활성화
          myLocationEnabled: myLocationEnabled, // 현재 위치 표시 활성화
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