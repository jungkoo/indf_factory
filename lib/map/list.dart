import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:indf_factory/board/list.dart';
import 'package:indf_factory/extensions/google_map.dart';
import 'package:indf_factory/indf_location.dart';
import 'package:indf_factory/indf_supabase.dart';

class SupabaseLocationListWidget extends StatefulWidget {
  final RenderBuilder renderBuilder;
  final MarkerBuilder markerBuilder;
  final QueryBuilder queryBuilder;
  final int pageSize;
  final double zoom;
  final double minDistanceMeters;

  const SupabaseLocationListWidget({
    super.key,
    required this.queryBuilder,
    required this.markerBuilder,
    required this.renderBuilder,
    this.pageSize = 10,
    this.zoom = 15.0,
    this.minDistanceMeters = 100
  });

  @override
  State<StatefulWidget> createState() => _SupabaseLocationListWidgetState();
}

class _SupabaseLocationListWidgetState extends State<SupabaseLocationListWidget> {
  late QueryParameter queryParameter;
  late LatLng _initialLocation;
  late LatLng _mapLocation;
  Timer? _debounceTimer; // 지도 이동 할때 잦은 호출을 막기 위한 방법
  bool _isLoading = true;
  bool _isFirstLoad = false;


  @override
  void initState() {
    super.initState();
    LocationInstance().currentLocation().then((location){
      setState(() {
        queryParameter = QueryParameter(
          parameters: {},
          pageNum: 1,
          pageSize: widget.pageSize,
          location: location,
        );
        _initialLocation = location;
        _mapLocation = location;
        _isLoading = false;
        _isFirstLoad = true;
      });
      _isFirstLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      debugPrint("*** build : 로딩중");
      return Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        _createMapWidget(),
        _createDraggableScrollableSheet(),
      ],
    );
  }


  // 지도 그리기
  Widget _createMapWidget() {
    return FutureBuilder<List<Map<String, dynamic>>> (
      future: searchMapData(),
      builder: (context, snapshot) {
        if (_isFirstLoad && snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else  if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return Center(child: Text('오류가 발생했습니다.'));
        } else if (snapshot.hasData) {
          final List<Map<String, dynamic>> data = snapshot.data!;
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _mapLocation,
              zoom: widget.zoom,
            ),
            myLocationButtonEnabled: true, // 현재 위치 버튼 활성화
            myLocationEnabled: true, // 현재 위치 표시 활성화
            zoomControlsEnabled: true, // 줌확대 버튼 활성화
            zoomGesturesEnabled: true, // 손가락 핀치로 확대 활성화
            markers: (data.map((item) => widget.markerBuilder(item)).whereType<Marker>().toSet()).deduplicate(),
            circles: <Circle>{_initialLocation.currentCircle},
            onCameraMove: (position) {
              _debounceTimer?.cancel();
              _debounceTimer = Timer(Duration(seconds: 1), () {
                if (_isLoading || !mounted) return;
                if (position.target == queryParameter.location) return; // 위치가 같으면 업데이트 X
                if (_mapLocation.distanceMeters(position.target) < widget.minDistanceMeters) return; // 너무 가까우면 무시
                _isLoading = true;
                setState(() {
                  _mapLocation = position.target;
                  queryParameter.location = _mapLocation;
                  queryParameter.pageNum = 1;
                });
                _isLoading = false;
              });
            },
          );
        } else {
          return Text("데이터 없음");
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchMapData() async {
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

  Widget _createDraggableScrollableSheet() {
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
              Expanded(child: _createAutoListWidget(scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _createAutoListWidget(ScrollController scroller) {
    return SupabaseAutoScrollListWidget(
        key: ValueKey(_mapLocation),
        queryBuilder: widget.queryBuilder,
        renderBuilder: widget.renderBuilder,
        queryParameter: queryParameter,
        scrollController: scroller,
    );
  }
}