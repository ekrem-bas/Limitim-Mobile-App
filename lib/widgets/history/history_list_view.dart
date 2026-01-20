import 'package:flutter/material.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/widgets/history/history_list_item.dart';

class HistoryListView extends StatelessWidget {
  final List<Month> archivedMonths;
  const HistoryListView({super.key, required this.archivedMonths});

  @override
  Widget build(BuildContext context) {
    // Ayları yıla ve aya göre tersten sıralayalım (en yeni en üstte)
    final sortedMonths = List<Month>.from(archivedMonths)
      ..sort((a, b) {
        // Önce yıla, sonra ay ismine/ID'sine göre sıralama mantığı kurulabilir
        return b.id.compareTo(
          a.id,
        ); // ID genellikle timestamp olduğu için pratik bir çözüm
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
