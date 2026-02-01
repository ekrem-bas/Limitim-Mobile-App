import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:limitim/core/utils/currency_helper.dart';
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
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. expense title
              Text(
                expense.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 2. expense amount
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Text(
                      "Tutar: ",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${CurrencyHelper.format(expense.amount)} ₺",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // 3. expense date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(expense.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(), // push time to the right
                ],
              ),
            ],
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
