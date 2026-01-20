import 'package:flutter/material.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/widgets/expense/expense_list_item.dart';

class ExpenseListView extends StatelessWidget {
  final List<Expense> expenses;
  const ExpenseListView({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedExpenses.isEmpty) {
      return _emptyView(context);
    }
    return ListView.builder(
      itemCount: sortedExpenses.length,
      padding: EdgeInsets.only(bottom: 80, top: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final expense = sortedExpenses[index];
        return ExpenseListItem(expense: expense);
      },
    );
  }

  Center _emptyView(BuildContext context) {
    final String warningMessage =
        "Henüz bir harcama eklemediniz.\nAlttaki + butonuna basarak başlayın.";
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(height: 10),
            Text(
              warningMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
