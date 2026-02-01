import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/theme/app_theme.dart';
import 'package:limitim/core/utils/currency_helper.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/features/history/widgets/history_detail_page.dart';
import 'package:limitim/core/widgets/dismissible_card.dart';

class HistoryListItem extends StatelessWidget {
  final Month month;
  const HistoryListItem({super.key, required this.month});

  final String _limitTextPrefix = "Limit";
  final String _totalExpenseTextPrefix = "Toplam Harcama";
  final String _remainingLimitTextPrefix = "Kalan Limit";

  @override
  Widget build(BuildContext context) {
    return DismissibleCard(
      id: month.id,
      onDismissed: (_) {
        context.read<HistoryBloc>().add(DeleteHistoryMonthEvent(month.id));
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailPage(month: month),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. title and icon
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.calendar_month,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      month.displayTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 20),

              // 2. data sections
              _buildDataSection(
                context,
                label: _limitTextPrefix,
                value: CurrencyHelper.format(month.limit),
              ),
              const Divider(height: 24), // Seperator

              _buildDataSection(
                context,
                label: _totalExpenseTextPrefix,
                value: CurrencyHelper.format(month.totalSpent),
                valueColor: Theme.of(
                  context,
                ).extension<AppColors>()?.expenseColor,
              ),
              const Divider(height: 24), // Seperator

              _buildDataSection(
                context,
                label: _remainingLimitTextPrefix,
                value: CurrencyHelper.format(month.limit - month.totalSpent),
                valueColor: Theme.of(
                  context,
                ).extension<AppColors>()?.limitColor,
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        // value below
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              "$value ₺",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
