import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (direction) {
        // trigger delete event in the bloc
        context.read<ActiveSessionBloc>().add(DeleteExpenseEvent(expense.id));

        // give user feedback
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${expense.title} silindi')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: ListTile(
          title: Text(
            capitalize(expense.title),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: Text(
            "${expense.amount.toStringAsFixed(2)} ₺",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
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

String capitalize(String text) {
  if (text.isEmpty) return text;
  // toBeginningOfSentenceCase hem ilk harfi büyütür hem de Türkçe karakter desteği sunar.
  return toBeginningOfSentenceCase(text.toLowerCase()) ?? text;
}
