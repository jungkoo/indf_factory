import 'package:flutter/material.dart';

/*
 * Map<String, dynamic> 데이터를 간단히 확인하는 위젯
 */
class MapDisplayWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const MapDisplayWidget({
    super.key,
    required this.data,
    this.title = 'Map Data Display',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              ...data.entries.map((entry) => _buildDataItem(entry.key, entry.value)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(String key, dynamic value) {
    Widget valueWidget;

    if (value is Map<String, dynamic>) {
      valueWidget = ExpansionTile(
        title: Text(key),
        children: value.entries.map((entry) =>
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildDataItem(entry.key, entry.value),
            )
        ).toList(),
      );
    } else if (value is List) {
      valueWidget = ExpansionTile(
        title: Text('$key (${value.length} items)'),
        children: List.generate(
          value.length,
              (i) => Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildDataItem('[$i]', value[i]),
          ),
        ),
      );
    } else {
      valueWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$key: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Expanded(
              child: Text(
                value?.toString() ?? 'null',
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return valueWidget;
  }
}
