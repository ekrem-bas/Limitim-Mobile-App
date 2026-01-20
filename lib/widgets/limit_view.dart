import 'package:flutter/material.dart';
import 'package:limitim/theme/app_theme.dart';

class LimitView extends StatelessWidget {
  final double limit;
  final double totalExpense;
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
                  'Limit: ${(limit - totalExpense).toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).extension<AppColors>()?.success ??
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
                  'Harcama: ${totalExpense.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).extension<AppColors>()?.danger ??
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
