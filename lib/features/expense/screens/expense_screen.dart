import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/expense/widgets/add_expense_sheet.dart';
import 'package:limitim/features/expense/widgets/expense_list_view.dart';
import 'package:limitim/core/widgets/limit_view.dart';
import 'package:limitim/core/widgets/set_limit_sheet.dart';
import 'package:limitim/features/expense/widgets/save_expenses_sheet.dart';

class ExpenseScreen extends StatelessWidget {
  final String _titleExpense = "Harcamalar";
  final String _endSessionTooltip = "Dönemi Bitir ve Kaydet";
  final String _startSessionTooltip = "Limit Belirle";
  final String _emptyStateText = "Aktif bir bütçe dönemi yok.";
  final String _emptyStateHintText = "Başlamak için alttaki butona tıklayın.";

  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titleExpense,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              if (state is SessionActive) {
                return Row(
                  children: [
                    // delete session button
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),

                    // save button
                    IconButton(
                      iconSize: 32,
                      onPressed: () => _showFinalizeSheet(context),
                      icon: Icon(Icons.save),
                      tooltip: _endSessionTooltip,
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NoActiveSession) {
            // state 1: there is no active session show empty state
            return _buildEmptyState(context);
          }

          if (state is SessionActive) {
            // state 2: there is an active session show expense list
            return Column(
              children: [
                InkWell(
                  onTap: () => _showSetLimit(
                    context,
                    initialLimit: state.activeMonth.limit,
                  ),
                  child: LimitView(
                    limit: state.activeMonth.limit,
                    totalExpense: state.totalSpent,
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: ExpenseListView(expenses: state.expenses)),
              ],
            );
          }

          if (state is SessionError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),

      floatingActionButton: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is NoActiveSession) {
            return FloatingActionButton.extended(
              onPressed: () => _showSetLimit(context),
              label: Text(_startSessionTooltip),
              icon: const Icon(Icons.add),
            );
          } else if (state is SessionActive) {
            return FloatingActionButton(
              onPressed: () => _showAddExpense(context),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _emptyStateText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(_emptyStateHintText),
        ],
      ),
    );
  }

  void _showSetLimit(BuildContext context, {double? initialLimit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // required for keyboard to push the sheet up
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SetLimitSheet(initialLimit: initialLimit),
    );
  }

  void _showAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // required for keyboard to push the sheet up
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddExpenseSheet(),
    );
  }

  void _showFinalizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SaveExpensesSheet(),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final String deleteSessionTooltip =
        "Mevcut harcamalarınız silinecek ve aktif dönem sonlandırılacaktır. Bu işlem geri alınamaz.";
    final String confirmButtonText = "Evet, Sıfırla";
    final String cancelButtonText = "Vazgeç";
    final String dialogTitle = "Dönemi İptal Et";

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(deleteSessionTooltip),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(cancelButtonText),
          ),
          TextButton(
            onPressed: () {
              context.read<SessionBloc>().add(ResetSessionEvent());
              Navigator.pop(dialogContext);
            },
            child: Text(
              confirmButtonText,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
