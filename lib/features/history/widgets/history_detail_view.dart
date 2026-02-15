import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/expense/widgets/expense_list_item.dart';
import 'package:limitim/features/export_csv/cubit/export_pdf_cubit.dart';
import 'package:limitim/features/export_csv/widgets/export_sheet.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/core/widgets/limit_view.dart';
import 'package:limitim/repository/hive_repository.dart';

class HistoryDetailView extends StatelessWidget {
  final Month month;

  const HistoryDetailView({super.key, required this.month});

  final String _exportSuccessfullMessage = "Rapor başarıyla oluşturuldu.";

  @override
  Widget build(BuildContext context) {
    // Fetch expenses for the given month
    final List<Expense> expenses = context
        .read<HiveRepository>()
        .getExpensesForMonth(month.id);

    return BlocProvider(
      create: (context) => ExportPdfCubit(),
      child: BlocListener<ExportPdfCubit, ExportPdfState>(
        listener: _handleExportState,
        child: _HistoryDetailBody(month: month, expenses: expenses),
      ),
    );
  }

  void _handleExportState(BuildContext context, ExportPdfState state) {
    if (state is ExportPdfSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_exportSuccessfullMessage)));
    } else if (state is ExportPdfFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata: ${state.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _HistoryDetailBody extends StatelessWidget {
  final Month month;
  final List<Expense> expenses;

  const _HistoryDetailBody({required this.month, required this.expenses});

  final String _emptyExpenseMessage = "Bu döneme ait harcama kaydı bulunamadı.";

  @override
  Widget build(BuildContext context) {
    final double totalSpent = expenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(context),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showExportSheet(context, totalSpent),
            icon: const Icon(Icons.file_upload_sharp),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: LimitView(limit: month.limit, totalExpense: totalSpent),
          ),
          const Divider(height: 1),
          Expanded(child: _buildReadOnlyExpenseList(context)),
        ],
      ),
    );
  }

  // --- Helper Metotlar (Kodun okunabilirliğini artıran parçalar) ---

  void _showExportSheet(BuildContext context, double totalSpent) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => ExportSheet(
        totalSpent: totalSpent,
        remainingLimit: month.limit,
        onExport: (fileName) =>
            _triggerPdfExport(context, fileName, totalSpent),
      ),
    );
  }

  void _triggerPdfExport(BuildContext context, String fileName, double total) {
    context.read<ExportPdfCubit>().exportToPdf(
      expenses: expenses,
      totalSpent: total,
      remainingLimit: month.limit - total,
      fileName: fileName,
    );
    Navigator.of(context).pop();
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          month.hasCustomName
              ? month.customName!
              : "${month.name} ${month.year}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (month.hasCustomName)
          Text(
            "${month.name} ${month.year}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildReadOnlyExpenseList(BuildContext context) {
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

    final sorted = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sorted.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) =>
          ExpenseListItem(expense: sorted[index], isReadOnly: true),
    );
  }
}
