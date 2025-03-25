import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AutoScrollWidget extends StatefulWidget {
  final PostgrestTransformBuilder transformBuilder;
  final int pageSize;
  final ItemWidgetBuilder<Map<String, dynamic>> itemBuilder;

  /// 자동 스크롤 위젯
  ///
  /// @param transformBuilder 데이터 변환 함수 : supabase 에서 range 이전까지
  /// @param itemBuilder 아이템 빌더 : 리스트 출력용 위젯
  /// @param pageSize 한 번에 가져올 데이터 개수
  const AutoScrollWidget({super.key, required this.transformBuilder, required this.itemBuilder, this.pageSize=10});

  @override
  State<StatefulWidget> createState() => AutoScrollWidgetState();
}

class AutoScrollWidgetState extends State<AutoScrollWidget> {
  bool _lastPage = false;

  late final PagingController<int, Map<String, dynamic>> _pagingController = PagingController<int, Map<String, dynamic>>(
    getNextPageKey: (state) => _lastPage ? null : (state.keys?.last ?? 0) + 1, // 다음 페이지 키를 가져오는 함수
    fetchPage: fetchPage, // 페이지를 가져오는 함수
  );


  @override
  Widget build(BuildContext context)=> PagingListener(
    controller: _pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<int, Map<String, dynamic>>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: widget.itemBuilder
      ),
    ),
  );

  Future<List<Map<String, dynamic>>> fetchPage(int pageKey) async {
    try {
      final pageSize = widget.pageSize;
      final response =  await widget.transformBuilder
          .range((pageKey-1) * pageSize, pageKey * pageSize - 1);
      final List<Map<String, dynamic>> newItems = List<Map<String, dynamic>>.from(response.data);
      _lastPage = newItems.length < pageSize;
      return newItems; // 새로운 방식에서는 데이터를 반환하면 자동 추가됨
    } catch (error) {
      throw Exception("데이터 로드 실패: $error"); // 오류 발생 시 예외 처리
    }
  }
}