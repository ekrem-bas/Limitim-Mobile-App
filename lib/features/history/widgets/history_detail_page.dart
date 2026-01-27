import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/expense/widgets/expense_list_item.dart';
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              month.hasCustomName
                  ? month.customName!
                  : "${month.name} ${month.year}",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            if (month.hasCustomName)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "${month.name} ${month.year}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 3. Display limit view
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: LimitView(limit: month.limit, totalExpense: totalSpent),
          ),
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
        return ExpenseListItem(expense: expense, isReadOnly: true);
      },
    );
  }
}
