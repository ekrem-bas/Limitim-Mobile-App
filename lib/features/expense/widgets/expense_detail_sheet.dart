import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/cubit/expense_detail_cubit.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/expense/widgets/update_expense_sheet.dart';

class ExpenseDetailSheet extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailSheet({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag handle
              const SizedBox(height: 12),
              _buildDragHandle(context),
              const SizedBox(height: 24),

              // 2. icon and title
              _buildHeader(context),
              const SizedBox(height: 32),

              // 3. detail info
              _buildDetailInfo(context),
              const SizedBox(height: 40),

              // 4. action buttons
              _buildActionButtons(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.onSurfaceVariant.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const String expenseDetailText = "Harcama Detayı";
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.shopping_bag_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Text(
                expenseDetailText,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo(BuildContext context) {
    const String amountLabel = "Tutar";
    const String currencyLabel = "₺";
    const String dateLabel = "Tarih";
    const String hourLabel = "Saat";
    return Column(
      children: [
        _infoTile(
          context,
          Icons.payments_outlined,
          amountLabel,
          "${expense.amount.toStringAsFixed(2)} $currencyLabel",
          isBold: true,
        ),
        const Divider(height: 32),
        _infoTile(
          context,
          Icons.calendar_today_outlined,
          dateLabel,
          "${expense.date.day}/${expense.date.month}/${expense.date.year}",
        ),
        const Divider(height: 32),
        _infoTile(
          context,
          Icons.access_time_outlined,
          hourLabel,
          "${expense.date.hour.toString().padLeft(2, '0')}:${expense.date.minute.toString().padLeft(2, '0')}",
        ),
      ],
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    const String editExpenseLabel = "Harcamayı Düzenle";
    const String deleteExpenseLabel = "Harcamayı Sil";
    return Column(
      children: [
        // Düzenle Butonu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => _onUpdate(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text(editExpenseLabel),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Sil Butonu
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _onDelete(context),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text(
              deleteExpenseLabel,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  void _onUpdate(BuildContext context) {
    // 1. Önce detay ekranını kapatıyoruz
    Navigator.pop(context);

    // 2. Güncelleme formunu açıyoruz
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => UpdateExpenseSheet(expense: expense),
    );
  }

  void _onDelete(BuildContext context) {
    const String deleteExpenseLabel = "Harcamayı Sil";
    const String confirmationMessage =
        "bu harcama kaydını silmek istediğinize emin misiniz?";
    const String cancelLabel = "Vazgeç";
    const String deleteLabel = "Sil";
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(deleteExpenseLabel),
          content: const Text(confirmationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(cancelLabel),
            ),
            TextButton(
              onPressed: () async {
                // 1. Cubit üzerinden silme işlemini başlat
                final success = await context
                    .read<ExpenseDetailCubit>()
                    .deleteExpense(expense.id);

                if (success && context.mounted) {
                  // 2. Diyaloğu ve ardından Detail Sheet'i kapat
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);

                  // 3. SessionBloc'u ana listeyi tazelemesi için tetikle
                  context.read<SessionBloc>().add(CheckActiveSession());
                }
              },
              child: const Text(
                deleteLabel,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
