import 'package:flutter/widgets.dart';
import 'package:indf_factory/supabase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef QueryBuilder = Future<List<Map<String, dynamic>>> Function(SupabaseClient client, int startRange, int endRange);
typedef RenderBuilder = Widget Function(BuildContext context, Map<String, dynamic> item, int index);


class SupabaseAutoScrollListWidget extends StatefulWidget {
  final QueryBuilder queryBuilder;
  final RenderBuilder renderBuilder;
  final int pageSize;

  /*
   * 자동 스크롤 위젯
   */
  const SupabaseAutoScrollListWidget({
    super.key,
    required this.queryBuilder,
    required this.renderBuilder,
    this.pageSize = 10,
  });

  @override
  State<SupabaseAutoScrollListWidget> createState() => _AutoScrollWidgetState();
}

class _AutoScrollWidgetState extends State<SupabaseAutoScrollListWidget> {
  bool lastPage = false;

  late final PagingController<int, Map<String, dynamic>> _pagingController = PagingController<int, Map<String, dynamic>>(
    getNextPageKey: (state) => lastPage ? null : (state.keys?.last ?? 0) + 1,
    fetchPage: fetchPage,
  );


  Future<List<Map<String, dynamic>>> fetchPage(int pageKey) async {
    try {
      final client = SupabaseInstance().client;
      final startRange = (pageKey - 1) * widget.pageSize;
      final endRange = pageKey * widget.pageSize - 1;
      final newItems = await widget.queryBuilder(client, startRange, endRange);
      lastPage = newItems.length < widget.pageSize;
      return newItems; // 새로운 방식에서는 데이터를 반환하면 자동 추가됨
    } catch (error) {
      throw Exception("데이터 로드 실패: $error"); // 오류 발생 시 예외 처리
    }
  }

  @override
  Widget build(BuildContext context) => PagingListener(
    controller: _pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<int, Map<String, dynamic>>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return widget.renderBuilder(context, item, index);
        },
      ),
    ),
  );
}