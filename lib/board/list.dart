import 'package:flutter/widgets.dart';
import 'package:indf_factory/supabase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef QueryBuilder<ItemType> = PostgrestTransformBuilder<List<ItemType>> Function(SupabaseClient client, int startRange, int endRange);
typedef RenderBuilder<ItemType> = Widget Function(BuildContext context, ItemType item, int index);


class SupabaseAutoScrollListWidget<ItemType> extends StatefulWidget {
  final QueryBuilder<ItemType> queryBuilder;
  final RenderBuilder<ItemType> itemBuilder;
  final int pageSize;

  /*
   * 자동 스크롤 위젯
   */
  const SupabaseAutoScrollListWidget({
    super.key,
    required this.queryBuilder,
    required this.itemBuilder,
    this.pageSize = 10,
  });

  @override
  State<SupabaseAutoScrollListWidget<ItemType>> createState() => _AutoScrollWidgetState<ItemType>();
}

class _AutoScrollWidgetState<ItemType> extends State<SupabaseAutoScrollListWidget<ItemType>> {
  bool lastPage = false;

  late final PagingController<int, ItemType> _pagingController = PagingController<int, ItemType>(
    getNextPageKey: (state) => lastPage ? null : (state.keys?.last ?? 0) + 1,
    fetchPage: fetchPage,
  );


  Future<List<ItemType>> fetchPage(int pageKey) async {
    try {
      final client = SupabaseInstance().client;
      final startRange = (pageKey - 1) * widget.pageSize;
      final endRange = pageKey * widget.pageSize - 1;
      final newItems = await widget.queryBuilder(client, startRange, endRange);

      // pageSize 보다 적다면 마지막 페이지 임
      lastPage = newItems.length < widget.pageSize;
      return newItems; // 새로운 방식에서는 데이터를 반환하면 자동 추가됨
    } catch (error) {
      throw Exception("데이터 로드 실패: $error"); // 오류 발생 시 예외 처리
    }
  }

  @override
  Widget build(BuildContext context) => PagingListener(
    controller: _pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<int, ItemType>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return widget.itemBuilder(context, item, index);
        },
      ),
    ),
  );
}