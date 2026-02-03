import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:limitim/core/theme/cubit/text_scale_cubit.dart';
import 'package:limitim/core/utils/currency_helper.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/cubit/expense_detail_cubit.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/expense/widgets/update_expense_sheet.dart';

class ExpenseDetailSheet extends StatelessWidget {
  final Expense expense;
  final bool isReadOnly;
  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      // prevent the sheet from exceeding 95% of screen height
      constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // when content is too long, make it scrollable
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildDetailInfo(context),
                  const SizedBox(height: 40),
                  if (!isReadOnly) ...[
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const String expenseDetailText = "Harcama Detayı";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
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

    // check current text scale
    final double currentScale = context.watch<TextScaleCubit>().state;

    // if the scale is larger than 1.2, consider it as large font
    final bool isLargeFont = currentScale > 1.2;

    final String dateText = DateFormat('dd.MM.yyyy').format(expense.date);
    final String dayName = DateFormat('EEEE', 'tr_TR').format(expense.date);

    final String dateValue = isLargeFont
        ? "$dateText\n$dayName"
        : "$dateText $dayName";

    return Column(
      children: [
        _infoTile(
          context,
          Icons.payments_outlined,
          amountLabel,
          "${CurrencyHelper.format(expense.amount)} $currencyLabel",
          isBold: true,
        ),
        const Divider(height: 32),
        _infoTile(
          context,
          Icons.calendar_today_outlined,
          dateLabel,
          dateValue,
          isMultiline: isLargeFont,
        ),
        const Divider(height: 32),
        _infoTile(
          context,
          Icons.access_time_outlined,
          hourLabel,
          DateFormat('HH:mm').format(expense.date),
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
    bool isMultiline = false,
  }) {
    return Row(
      // if multiline, align to start
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isMultiline ? 4 : 0),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(width: 12),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? Theme.of(context).colorScheme.error : null,
                height: 1.3,
              ),
            ),
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
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
