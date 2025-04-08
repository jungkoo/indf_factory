# 개요
## 1. View
### 1.1 MapDisplayWidget
`Map<String, dynamic>` 타입의 데이터를 개발중 가볍게 확인할 수 있는 위젯이다.
개발 중 빠르게 결과를 확인하는 용도로 사용한다.

```dart
class MapDisplayExample extends StatelessWidget {
  final Map<String, dynamic> sampleData = {
    'name': '홍길동',
    'age': 30,
    'isActive': true,
    'scores': [85, 90, 75, 95],
    'address': {
      'city': '서울',
      'district': '강남구',
      'zipCode': '12345'
    },
    'contacts': [
      {'type': 'email', 'value': 'example@mail.com'},
      {'type': 'phone', 'value': '010-1234-5678'}
    ],
    'nullable': null,
  };

  MapDisplayExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map 데이터 표시'),
        backgroundColor: Colors.blueAccent,
      ),
      body: MapDisplayWidget(
        data: sampleData,
        title: '사용자 정보',
      ),
    );
  }
}
```


## 2. List
### 2.1 SupabaseAutoScrollListWidget
supabase 의 쿼리 결과를 오토 스크롤 처리를 해준다.
쿼리는 queryBuilder 에서 구성하고, 결과는 renderBuilder 에서 구성하면 된다.
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {   
    SupabaseInstance().initialize(
        'URL 입력',
        'KEY 입력'
    );
    runApp(const MyApp());
}

Widget build(BuildContext context) {
// ...
    Expanded(
      child: SupabaseAutoScrollListWidget(
        pageSize: 5,
        queryBuilder: (SupabaseClient client, int startRange, int endRange) async {
          final response = await client.rpc('shop_service_distance', params: {
            'p_name' : null,
            'p_category' : null,
            'p_limit' : 5,
            'p_offset': startRange,
            'p_x': null,
            'p_y': null,
            'p_distance': 1000,
          });
          return response.toList();
        },
        renderBuilder: (context, item, index) {
          return MapDisplayWidget(title: "index: $index 결과", data: item);
        },
      ),
    )
// ...
}
```