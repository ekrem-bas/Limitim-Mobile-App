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
                return IconButton(
                  iconSize: 32,
                  onPressed: () => _showFinalizeSheet(context),
                  icon: Icon(Icons.save),
                  tooltip: _endSessionTooltip,
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
            // DURUM 1: Limit belirlenmemişse gösterilecek boş ekran
            return _buildEmptyState(context);
          }

          if (state is SessionActive) {
            // DURUM 2: Aktif oturum varsa Özet + Liste
            return Column(
              children: [
                // Senin hazırladığın limit görünümü widget'ı
                LimitView(
                  limit: state.activeMonth.limit,
                  totalExpense: state.totalSpent,
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

  void _showSetLimit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavyenin düzgün çalışması için şart
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SetLimitSheet(),
    );
  }

  void _showAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavyenin sheet'i yukarı itmesi için şart
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
      backgroundColor: Colors
          .transparent, // Arka planı transparan yapıp Container'da şekil veriyoruz
      builder: (context) => const SaveExpensesSheet(),
    );
  }
}
