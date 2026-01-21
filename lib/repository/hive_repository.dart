import 'package:hive/hive.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/models/month.dart';

class HiveRepository {
  Box<Month> get _monthBox => Hive.box<Month>('months');
  Box<Expense> get _expenseBox => Hive.box<Expense>('expenses');

  // --- SESSION (DRAFT) MANAGEMENT ---

  // Is there currently an active spending session (limit set)?
  Month? getActiveSession() {
    try {
      return _monthBox.values.firstWhere((month) => month.isDraft == true);
    } catch (e) {
      return null; // If no draft exists, return null (State 1: Request Limit)
    }
  }

  // Start new session with given limit
  Future<void> startNewSession(double limit) async {
    final newMonth = Month(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Aktif Oturum",
      limit: limit,
      isDraft: true,
      createdAt: DateTime.now(),
    );
    await _monthBox.put(newMonth.id, newMonth);
  }

  // When user finalizes the session, we update the month details
  Future<void> finalizeSession({
    required String monthId,
    required String finalName,
    required int finalYear,
  }) async {
    final month = _monthBox.get(monthId);
    if (month != null) {
      month.name = finalName;
      month.year = finalYear;
      month.isDraft = false; // Mark as finalized
      await _monthBox.put(month.id, month);
    }
  }

  // --- EXPENSE OPERATIONS ---

  List<Expense> getExpensesForMonth(String monthId) {
    return _expenseBox.values
        .where((expense) => expense.monthId == monthId)
        .toList();
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  // --- CALCULATIONS ---

  double getTotalSpent(String monthId) {
    return _expenseBox.values
        .where((e) => e.monthId == monthId)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getRemainingBudget(String monthId) {
    final month = _monthBox.get(monthId);
    if (month == null) return 0.0;
    final totalSpent = getTotalSpent(monthId);
    return month.limit - totalSpent;
  }

  // --- HISTORY OPERATIONS ---

  List<Month> getArchivedMonths() {
    final history = _monthBox.values.where((m) => m.isDraft == false).toList();
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }

  Future<void> deleteArchivedMonth(String monthId) async {
    // Delete the month
    await _monthBox.delete(monthId);

    // Delete all expenses associated with this month
    final expensesToDelete = _expenseBox.values
        .where((expense) => expense.monthId == monthId)
        .toList();
    for (var expense in expensesToDelete) {
      await _expenseBox.delete(expense.id);
    }
  }
}
