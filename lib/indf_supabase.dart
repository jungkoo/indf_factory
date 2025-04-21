
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SupabaseClient 를 사용하여 데이터를 가져오는 함수 표현
typedef QueryBuilder = Future<List<dynamic>> Function(SupabaseClient client, Map<String, String> parameters, int startRange, int endRange);

// QueryBuilder 의 결과를 widget 으로 만드는 함수 표현
typedef RenderBuilder = Widget Function(BuildContext context, Map<String, dynamic> item, int index);


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