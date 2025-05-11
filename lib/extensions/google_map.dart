import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LatLngExtension on LatLng {

  // 랜덤하게 좌표를 조금 변경합니다
  LatLng get adjust {
    return LatLng(
      latitude + (Random().nextDouble() / 10000),
      longitude + (Random().nextDouble() / 10000),
    );
  }

  Circle get currentCircle {
    return Circle(
      circleId: CircleId('currentLocation'),
      center: this,
      radius: 200,
      fillColor: Colors.yellow.withAlpha(76),
      strokeColor: Colors.orange,
      strokeWidth: 2,
    );
  }

  double distanceMeters(LatLng other) {
    const earthRadius = 6371000; // in meters
    final dLat = (other.latitude - latitude) * pi / 180;
    final dLon = (other.longitude - longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(latitude * pi / 180) * cos(other.latitude * pi / 180) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
}

extension MarkerExtension on Marker {
  // 마커의 위치를 조금 변경합니다
  Marker get adjustPosition {
    return Marker(
      markerId: markerId,
      position: position.adjust,
      infoWindow: InfoWindow(
        title: infoWindow.title,
        snippet: infoWindow.snippet,
      ),
      icon: icon,
    );
  }
}

extension MarkerSetExtension on Set<Marker> {

  /*
   * 구글지도에서 마커가 완벽하게 동일하면 1개만 나오는 문제가 있어서 같은값이 있으면 조금이라도 위치를 다르게 가져간다
   */
  Set<Marker> deduplicate() {
    final originalMarkers = this;
    final Set<LatLng> duplicationCheck = {};
    final Set<Marker> deduplicate = {};
    for(final marker in originalMarkers) {
      if (!duplicationCheck.contains(marker.position)) {
        deduplicate.add(marker);
        duplicationCheck.add(marker.position);
        continue;
      }
      // 중복된 값이 존재함
      while(true) {
        final adjustMarker = marker.adjustPosition;
        if (!duplicationCheck.contains(adjustMarker.position)) {
          deduplicate.add(adjustMarker);
          duplicationCheck.add(adjustMarker.position);
          break;
        }
      }
    }
    return deduplicate;
  }
}