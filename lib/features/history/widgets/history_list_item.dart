import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/features/history/widgets/history_detail_page.dart';
import 'package:limitim/core/widgets/dismissible_card.dart';

class HistoryListItem extends StatelessWidget {
  final Month month;
  const HistoryListItem({super.key, required this.month});

  final String _limitTextPrefix = "Limit: ";
  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      id: month.id,
      onDismissed: (_) {
        context.read<HistoryBloc>().add(DeleteHistoryMonthEvent(month.id));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(Icons.calendar_month, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              month.displayTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Text("$_limitTextPrefix${month.limit.toStringAsFixed(2)} ₺"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailPage(month: month),
            ),
          );
        },
      ),
    );
  }
}
