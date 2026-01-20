import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/widgets/expense/add_expense_sheet.dart';
import 'package:limitim/widgets/expense/expense_list_view.dart';
import 'package:limitim/widgets/expense/save_expenses_sheet.dart';
import 'package:limitim/widgets/limit_view.dart';
import 'package:limitim/widgets/set_limit_sheet.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harcamalarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
            builder: (context, state) {
              if (state is SessionActive) {
                return IconButton(
                  iconSize: 32,
                  onPressed: () => _showFinalizeSheet(context),
                  icon: Icon(Icons.save),
                  tooltip: "Dönemi Bitir ve Kaydet",
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
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

      floatingActionButton: BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
        builder: (context, state) {
          if (state is NoActiveSession) {
            return FloatingActionButton.extended(
              onPressed: () => _showSetLimit(context),
              label: const Text("Limit Belirle"),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aktif bir bütçe dönemi yok.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Text("Başlamak için alttaki butona tıklayın."),
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
