import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/core/widgets/limit_view.dart';
import 'package:limitim/repository/hive_repository.dart';

class HistoryDetailPage extends StatelessWidget {
  final Month month;

  const HistoryDetailPage({super.key, required this.month});

  final String _emptyExpenseMessage = "Bu döneme ait harcama kaydı bulunamadı.";

  @override
  Widget build(BuildContext context) {
    // 1. Fetch expenses for the given month
    final List<Expense> expenses = context
        .read<HiveRepository>()
        .getExpensesForMonth(month.id);

    // 2. Calculate total spent in the month
    final double totalSpent = expenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("${month.name} ${month.year}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3. Display limit view
          LimitView(limit: month.limit, totalExpense: totalSpent),
          const Divider(height: 1),
          Expanded(child: _buildReadOnlyExpenseList(context, expenses)),
        ],
      ),
    );
  }

  Widget _buildReadOnlyExpenseList(
    BuildContext context,
    List<Expense> expenses,
  ) {
    if (expenses.isEmpty) {
      return Center(
        child: Text(
          _emptyExpenseMessage,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    // Sort expenses by date (newest first)
    expenses.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: expenses.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          elevation: 0.5,
          child: ListTile(
            title: Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "${expense.date.day}/${expense.date.month}/${expense.date.year}",
            ),
            trailing: Text(
              "${expense.amount.toStringAsFixed(2)} ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
