import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indf_factory/extensions/google_map.dart';
import 'location.dart';

class LocationViewWidget extends StatelessWidget {
  final Set<Marker> marker;
  final Circle? circle;
  final double zoom;
  final bool myLocationButtonEnabled;
  final bool myLocationEnabled;
  final Function(LatLng location)? onChangeLocation;
  final LatLng? initialLocation;

  const LocationViewWidget({
    super.key,
    required this.marker,
    this.onChangeLocation,
    this.circle,
    this.zoom=13.0,
    this.myLocationButtonEnabled=true,
    this.myLocationEnabled=true,
    this.initialLocation
  });

  @override
  Widget build(BuildContext context) {
    return LocationBuilder(
      builder: (context, location) {
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLocation??location,
            zoom: zoom,
          ),
          myLocationButtonEnabled: myLocationButtonEnabled, // 현재 위치 버튼 활성화
          myLocationEnabled: myLocationEnabled, // 현재 위치 표시 활성화
          markers: marker.deduplicate(),
          circles: <Circle>{location.currentCircle},
          onCameraMove: (CameraPosition position) {
            print("onCameraMove ==> ${position.target}");
            onChangeLocation?.call(position.target);
          },
        );
      },
    );
  }



}