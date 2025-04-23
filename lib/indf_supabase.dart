
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SupabaseClient 를 사용하여 데이터를 가져오는 함수 표현
typedef QueryBuilder = Future<List<dynamic>> Function(SupabaseClient client, QueryParameter queryParameter);

// QueryBuilder 의 결과를 widget 으로 만드는 함수 표현
typedef RenderBuilder = Widget Function(BuildContext context, Map<String, dynamic> item, int index);

// 사용자 검색을 처리하기위한 파라미터 클래스
class QueryParameter {
  LatLng? location;
  Map<String, String> parameters;
  int pageNum;
  final int pageSize;

  QueryParameter({
    this.location,
    required this.parameters,
    this.pageNum = 1,
    this.pageSize = 10,
  });

  int get startRange => (pageNum - 1) * pageSize;
  int get endRange => pageNum * pageSize;

  @override
  String toString() {
    return "QueryParameter(location: $location, parameters: $parameters, pageNum: $pageNum, pageSize: $pageSize)";
  }
}

class SupabaseInstance {

  static final SupabaseInstance _instance = SupabaseInstance._internal();

  factory SupabaseInstance() {
    return _instance;
  }

  /*
   * Main 에서 선 초기화 필요함
   * await SupabaseInstance().initialize(url, key);
   */
  initialize(String url, String key) async {
    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
  }

  SupabaseInstance._internal();

  SupabaseClient get client => Supabase.instance.client;
}