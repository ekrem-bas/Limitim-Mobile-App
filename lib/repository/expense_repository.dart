import 'package:hive/hive.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/models/month.dart';

class ExpenseRepository {
  // box references
  Box<Month> get _monthBox => Hive.box<Month>('months');
  Box<Expense> get _expenseBox => Hive.box<Expense>('expenses');

  // ----- Month operations -----
  // get all months sorted by startDate descending
  List<Month> getAllMonths() {
    final months = _monthBox.values.toList();
    // Newest month first
    months.sort((a, b) => b.startDate.compareTo(a.startDate));
    return months;
  }

  // get latest created month as active month
  Month? getActiveMonth() {
    if (_monthBox.isEmpty) return null;
    // the last added month is the active month
    return _monthBox.values.last;
  }

  // add a new month
  Future<void> addMonth(Month month) async {
    await _monthBox.add(month);
  }

  // ----- Expense operations -----
  // get expenses for a specific month
  List<Expense> getExpensesForMonth(String monthId) {
    return _expenseBox.values
        .where((expense) => expense.monthId == monthId)
        .toList();
  }

  // add a new expense
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.add(expense);
  }

  // delete an expense
  Future<void> deleteExpense(int expenseKey) async {
    await _expenseBox.delete(expenseKey);
  }

  // ----- Calculate the total expenses for a month -----
  double getTotalExpensesForMonth(String monthId) {
    final expenses = getExpensesForMonth(monthId);
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // ----- Calculate the remaining budget for a month -----
  double getRemainingBudgetForMonth(String monthId) {
    final limit = _monthBox.values
        .firstWhere((month) => month.id == monthId)
        .limit;
    final totalExpenses = getTotalExpensesForMonth(monthId);
    return limit - totalExpenses;
  }
}
