
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef QueryBuilder = Future<List<dynamic>> Function(SupabaseClient client, int startRange, int endRange);
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