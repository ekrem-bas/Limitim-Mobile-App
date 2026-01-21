import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/core/widgets/dismissible_card.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      id: expense.id,
      onDismissed: (direction) {
        context.read<SessionBloc>().add(DeleteExpenseEvent(expense.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${expense.title} silindi')));
      },
      child: ListTile(
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "${expense.date.day}/${expense.date.month}/${expense.date.year}",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          "${expense.amount.toStringAsFixed(2)} ₺",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
