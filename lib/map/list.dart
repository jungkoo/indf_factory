import 'package:flutter/material.dart';

class LocationFeedWidget extends StatelessWidget  {
  const LocationFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        _createGoogleMap(),
        DraggableScrollableSheet(
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
                  Expanded(child: _createFeed(scrollController)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _createGoogleMap() {
    return Text("");
  }

  Widget _createFeed(ScrollController scrollController) {
    return Text("");
  }
}