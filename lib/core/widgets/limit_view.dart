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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Limit section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    limitText.trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context)
                              .extension<AppColors>()
                              ?.limitColor
                              ?.withValues(alpha: 0.8) ??
                          Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${(limit - totalExpense).toStringAsFixed(2)} ₺',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(
                              context,
                            ).extension<AppColors>()?.limitColor ??
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 40,
              width: 1,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),

            // Expense section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expenseText.trim(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context)
                              .extension<AppColors>()
                              ?.expenseColor
                              ?.withValues(alpha: 0.8) ??
                          Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${totalExpense.toStringAsFixed(2)} ₺',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(
                              context,
                            ).extension<AppColors>()?.expenseColor ??
                            Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
