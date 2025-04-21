import 'package:flutter/widgets.dart';
import 'package:indf_factory/indf_supabase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
      final dynamicList = await widget.queryBuilder(client, startRange, endRange);
      if (dynamicList.any((element) => element is! Map<String, dynamic>)) {
        throw Exception("queryResult 에 Map<String, dynamic> 타입이 아닌 요소가 포함되어 있습니다.");
      }
      final List<Map<String, dynamic>> queryResult = dynamicList.cast<Map<String, dynamic>>();
      lastPage = queryResult.length < widget.pageSize;
      return queryResult; // 새로운 방식에서는 데이터를 반환하면 자동 추가됨
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