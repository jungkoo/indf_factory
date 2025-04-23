import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indf_factory/board/list.dart';
import 'package:indf_factory/indf_location.dart';
import 'package:indf_factory/map/location.dart';
import 'package:indf_factory/map/view.dart';
import '../indf_supabase.dart';

class SupabaseLocationListWidget extends StatefulWidget {
  final RenderBuilder renderBuilder;
  final MarkerBuilder markerBuilder;
  final QueryBuilder queryBuilder;
  final int pageSize;

  const SupabaseLocationListWidget({
    super.key,
    required this.queryBuilder,
    required this.markerBuilder,
    required this.renderBuilder,
    this.pageSize = 10
  });

  @override
  State<StatefulWidget> createState() => _SupabaseLocationListWidgetState();
}

class _SupabaseLocationListWidgetState extends State<SupabaseLocationListWidget> {
  late QueryParameter queryParameter;

  @override
  void initState() {
    super.initState();
    queryParameter = QueryParameter(
      parameters: {},
      pageNum: 1,
      pageSize: widget.pageSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LocationBuilder(
      builder: (context, location) {
        return Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            _createMapWidget(location),
            _createDraggableScrollableSheet(location),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchMapData(LatLng location) async {
    try {
      final client = SupabaseInstance().client;

      final dynamicList = await widget.queryBuilder(client, queryParameter);
      if (dynamicList.any((element) => element is! Map<String, dynamic>)) {
        throw Exception("queryResult 에 Map<String, dynamic> 타입이 아닌 요소가 포함되어 있습니다.");
      }
      final List<Map<String, dynamic>> queryResult = dynamicList.cast<Map<String, dynamic>>();
      return queryResult; // 새로운 방식에서는 데이터를 반환하면 자동 추가됨
    } catch (error) {
      throw Exception("데이터 로드 실패: $error"); // 오류 발생 시 예외 처리
    }
  }

  // 지도 그리기
  Widget _createMapWidget(LatLng location) {
    return FutureBuilder<List<Map<String, dynamic>>> (
      future: searchMapData(location),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Center(child: Text('오류가 발생했습니다.'));
        } else if (snapshot.hasData) {
          final List<Map<String, dynamic>> data = snapshot.data!;
          // print("markers ==> ${data.map((item) => widget.markerBuilder(item)).whereType<Marker>().toSet()}");
          return LocationViewWidget(
            marker: data.map((item) => widget.markerBuilder(item)).whereType<Marker>().toSet(),
            circle: null,
            zoom: 13.0,
            myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
            myLocationEnabled: true, // 현재 위치 표시 활성화
          );
        } else {
          return Text("데이터 없음");
        }
      },
    );
  }

  Widget _createDraggableScrollableSheet(LatLng location) {
    return  DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            children: [
              /// 🔹 **핸들바 (끌어서 조절하는 UI)**
              Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
              ),
              Expanded(child: _createAutoListWidget(scrollController, location)),
            ],
          ),
        );
      },
    );
  }

  Widget _createAutoListWidget(ScrollController scroller, LatLng location) {
    return SupabaseAutoScrollListWidget(
        queryBuilder: widget.queryBuilder,
        renderBuilder: widget.renderBuilder,
        queryParameter: queryParameter,
        scrollController: scroller,
    );
  }
}