import 'package:flutter/material.dart';
import 'package:limitim/core/theme/app_theme.dart';

class LimitView extends StatelessWidget {
  // limit - totalExpense
  final double limit;
  final double totalExpense;
  final String limitText = "Limit: ";
  final String expenseText = "Harcama: ";
  const LimitView({super.key, required this.limit, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$limitText ${(limit - totalExpense).toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).extension<AppColors>()?.limitColor ??
                        Theme.of(context).colorScheme.secondary,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '$expenseText ${totalExpense.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(
                          context,
                        ).extension<AppColors>()?.expenseColor ??
                        Theme.of(context).colorScheme.error,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
