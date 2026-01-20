import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/history_bloc/history_bloc.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/widgets/history/history_detail_page.dart';

class HistoryListItem extends StatelessWidget {
  final Month month;
  const HistoryListItem({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(month.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (_) {
        context.read<HistoryBloc>().add(DeleteHistoryMonthEvent(month.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        elevation: 2,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.calendar_month, color: Colors.white),
          ),
          title: Text(
            "${month.name} ${month.year}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Limit: ${month.limit.toStringAsFixed(2)} ₺"),
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
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: const Icon(Icons.delete_sweep, color: Colors.white),
    );
  }
}
