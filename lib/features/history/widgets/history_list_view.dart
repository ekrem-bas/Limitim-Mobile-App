import 'package:flutter/material.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/features/history/widgets/history_list_item.dart';

class HistoryListView extends StatelessWidget {
  final List<Month> archivedMonths;
  const HistoryListView({super.key, required this.archivedMonths});

  @override
  Widget build(BuildContext context) {
    // sort months by year and month in descending order
    final sortedMonths = List<Month>.from(archivedMonths)
      ..sort((a, b) {
        // firts sort by year, then by month name/ID
        return b.id.compareTo(a.id);
      });

    return ListView.builder(
      itemCount: sortedMonths.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return HistoryListItem(month: sortedMonths[index]);
      },
    );
  }
}
