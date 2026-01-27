import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/cubit/expense_detail_cubit.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/core/widgets/dismissible_card.dart';
import 'package:limitim/features/expense/widgets/expense_detail_sheet.dart';
import 'package:limitim/repository/hive_repository.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final bool isReadOnly;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      id: expense.id,
      direction: isReadOnly
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<SessionBloc>().add(DeleteExpenseEvent(expense.id));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${expense.title} silindi')));
      },
      child: ListTile(
        onTap: () => _showDetailSheet(context),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          "${expense.date.day}/${expense.date.month}/${expense.date.year}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          "${expense.amount.toStringAsFixed(2)} ₺",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => isReadOnly
          // if it is readOnly, show the sheet without BlocProvider (do not need to manage state)
          ? ExpenseDetailSheet(expense: expense, isReadOnly: true)
          : BlocProvider(
              // provide ExpenseDetailCubit to the sheet
              create: (context) =>
                  ExpenseDetailCubit(context.read<HiveRepository>()),
              child: ExpenseDetailSheet(
                expense: expense,
                isReadOnly: isReadOnly,
              ),
            ),
    );
  }
}
