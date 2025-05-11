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
  child: LocationViewWidget(marker: {marker})
),
```

## 2. List
### 2.1 SupabaseLocationListWidget
지도와 리스트형 데이터를 같이 보여준다.
(아직 QueryParameter 를 변경할 경우 재검색하여 처리하는 로직을 구현하지 않았다.)

```dart
Expanded(
  child: SupabaseLocationListWidget(
    queryBuilder: (SupabaseClient client, QueryParameter queryParameter) async {
      final String? keyword = queryParameter.parameters['keyword'];
      // 이런식으로 파라미터
      final response = await client.rpc('shop_service_distance', params: {
        'p_name' : null,
        'p_category' : null,
        'p_limit' : 5,
        'p_offset': queryParameter.startRange,
        'p_x': queryParameter.location?.longitude,
        'p_y': queryParameter.location?.latitude,
        'p_distance': 1000,
        }) ;
      return response.toList();
      },
    renderBuilder: (context, item, index) {
      return MapDisplayWidget(title: "index: $index 결과", data: item);
    },
    markerBuilder: (item) {
      if (item['x'] is! double || item['y'] is! double) {
        return null;
      }
      return Marker(
        markerId: MarkerId(item['shop_id'].toString()),
        position: LatLng(item['y']!, item['x']!),
        infoWindow: InfoWindow(
          title: item['name'],
          snippet: item['category'].toString(),
        ),
      );
    },
  ),
)
```