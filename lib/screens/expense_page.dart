import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/widgets/expense_list_view.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harcama Geçmişi')),
      body: BlocBuilder<ActiveSessionBloc, ActiveSessionState>(
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NoActiveSession) {
            // Durum 1: Henüz limit belirlenmemiş ekran
            return ExpenseListView(
              expenses: [
                Expense(
                  id: "1",
                  monthId: "1",
                  title: "Sebze",
                  amount: 150.0,
                  date: DateTime.parse("2024-06-21"),
                ),
                Expense(
                  id: "2",
                  monthId: "1",
                  title: "Meyve",
                  amount: 100.0,
                  date: DateTime.parse("2024-06-16"),
                ),
                Expense(
                  id: "3",
                  monthId: "1",
                  title: "Et",
                  amount: 250.0,
                  date: DateTime.parse("2024-06-17"),
                ),
              ],
            );
          } else if (state is SessionActive) {
            // Durum 2: Harcamaların listelendiği aktif ekran
            return Center(
              child: Text(
                'Active Month: ${state.activeMonth.name} ${state.activeMonth.year}\n'
                'Total Spent: ${state.totalSpent}\n'
                'Remaining Limit: ${state.remainingLimit}\n'
                'Expenses Count: ${state.expenses.length}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (state is SessionError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
