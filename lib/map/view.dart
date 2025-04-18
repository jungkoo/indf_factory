import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location.dart';
import 'dart:math';

class LocationViewWidget extends StatelessWidget {
  final Set<Marker> marker;
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
          markers: _createMarker(marker),
          circles: <Circle>{_createCircle(location)},
        );
      },
    );
  }

  // 좌표가 같으면 노출이 안되기 때문에 같으면 약간 어긋난 좌표를 만들어 준다
  Set<Marker> _createMarker(Set<Marker> originalMarkers) {
    final Set<LatLng> duplicationCheck = {};
    final Set<Marker> normalizeMarker = {};
    for(final marker in originalMarkers) {
      if (!duplicationCheck.contains(marker.position)) {
        normalizeMarker.add(marker);
        duplicationCheck.add(marker.position);
        continue;
      }
      // 중복된 값이 존재함
      while(true) {
        final LatLng changedPosition = LatLng(
          marker.position.latitude + (Random().nextDouble() / 10000),
          marker.position.longitude + (Random().nextDouble() / 10000),
        );
        if (!duplicationCheck.contains(changedPosition)) {
          normalizeMarker.add(Marker(
            markerId: marker.markerId,
            position: changedPosition,
            infoWindow: InfoWindow(
              title: marker.infoWindow.title,
              snippet: marker.infoWindow.snippet,
            ),
            icon: marker.icon,
          ));
          duplicationCheck.add(changedPosition);
          break;
        }
      }
    }
    return normalizeMarker;
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