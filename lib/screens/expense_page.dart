import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/widgets/expense/add_expense_sheet.dart';
import 'package:limitim/widgets/expense/expense_list_view.dart';
import 'package:limitim/widgets/expense/save_expenses_sheet.dart';
import 'package:limitim/widgets/limit_view.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcamalarım'),
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
            return _buildEmptyState();
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
              onPressed: () => _showLimitDialog(context),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
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

  void _showLimitDialog(BuildContext context) {
    final TextEditingController limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limit Belirle"),
        content: TextField(
          controller: limitController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: "Örn: 5000",
            suffixText: "₺",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(limitController.text);
              if (limit != null && limit > 0) {
                // BLoC'a yeni oturum başlatma emrini gönderiyoruz
                context.read<ActiveSessionBloc>().add(StartNewSession(limit));
                Navigator.pop(context);
              }
            },
            child: const Text("Başlat"),
          ),
        ],
      ),
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
