import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/repository/expense_repository.dart';
import 'package:limitim/widgets/limit_view.dart';

class HistoryDetailPage extends StatelessWidget {
  final Month month;

  const HistoryDetailPage({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    // 1. Repository üzerinden bu aya ait harcamaları çekiyoruz
    final List<Expense> expenses = context
        .read<ExpenseRepository>()
        .getExpensesForMonth(month.id);

    // 2. Toplam harcamayı hesaplıyoruz
    final double totalSpent = expenses.fold(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("${month.name} ${month.year}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // LimitView'a verileri gönderiyoruz
          LimitView(limit: month.limit, totalExpense: totalSpent),
          const Divider(height: 1),
          Expanded(child: _buildReadOnlyExpenseList(expenses)),
        ],
      ),
    );
  }

  Widget _buildReadOnlyExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          "Bu döneme ait harcama kaydı bulunamadı.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Harcamaları tarihe göre sıralayalım
    expenses.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: expenses.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          elevation: 0.5,
          child: ListTile(
            title: Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "${expense.date.day}/${expense.date.month}/${expense.date.year}",
            ),
            trailing: Text(
              "${expense.amount.toStringAsFixed(2)} ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
