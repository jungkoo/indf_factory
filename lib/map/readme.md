# 개요
## 1. View
### 1.1 LocationViewWidget
특정 위치의 마커를 구글맵에 표시하는 위젯이다.

```dart
final marker = Marker(
  markerId: MarkerId('shop'),
  position: LatLng(37.3595704, 127.105399),
  infoWindow: InfoWindow(
    title: "제목",
    snippet: "내용",
  ),
);
...
SizedBox(
  width: 300,
  height: 400,
  child: LocationViewWidget(marker: marker)
),
```