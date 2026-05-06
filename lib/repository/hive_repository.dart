import 'package:hive/hive.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/repository/app_repository.dart';

class HiveRepository implements AppRepository {
  Box<Month> get _monthBox => Hive.box<Month>('months');
  Box<Expense> get _expenseBox => Hive.box<Expense>('expenses');

  // --- SESSION (DRAFT) MANAGEMENT ---

  // Is there currently an active spending session (limit set)?
  @override
  Month? getActiveSession() {
    try {
      return _monthBox.values.firstWhere((month) => month.isDraft == true);
    } catch (e) {
      return null; // If no draft exists, return null (State 1: Request Limit)
    }
  }

  // Start new session with given limit
  @override
  Future<void> startNewSession(
    double limit, {
    bool autoRollover = false,
  }) async {
    final newMonth = Month(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "Aktif Oturum",
      limit: limit,
      isDraft: true,
      createdAt: DateTime.now(),
      autoRollover: autoRollover,
    );
    await _monthBox.put(newMonth.id, newMonth);
  }

  // delete active session (draft)
  @override
  Future<void> resetActiveSession() async {
    final activeSession = getActiveSession();
    if (activeSession != null) {
      // Delete all expenses associated with this active session
      final expensesToDelete = _expenseBox.values
          .where((expense) => expense.monthId == activeSession.id)
          .toList();
      for (var expense in expensesToDelete) {
        await _expenseBox.delete(expense.id);
      }
      // Delete the active session month
      await _monthBox.delete(activeSession.id);
    }
  }

  // update active session limit
  @override
  Future<void> updateActiveSessionLimit(double newLimit) async {
    final activeSession = getActiveSession();
    if (activeSession != null) {
      final updatedMonth = activeSession.copyWith(limit: newLimit);
      await _monthBox.put(updatedMonth.id, updatedMonth);
    }
  }

  // update active session auto-rollover setting
  @override
  Future<void> updateAutoRollover(bool autoRollover) async {
    final activeSession = getActiveSession();
    if (activeSession != null) {
      final updatedMonth = activeSession.copyWith(
        autoRollover: autoRollover,
      );
      await _monthBox.put(updatedMonth.id, updatedMonth);
    }
  }

  // Turkish month names for auto-rollover naming
  static const List<String> _turkishMonths = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  // Auto-rollover: finalize current session with month name and start new one
  @override
  Future<void> autoRolloverSession() async {
    final activeSession = getActiveSession();
    if (activeSession == null) return;

    // Determine the month name from session's createdAt
    final monthName = _turkishMonths[activeSession.createdAt.month - 1];
    final year = activeSession.createdAt.year;

    // Finalize current session
    await finalizeSession(
      monthId: activeSession.id,
      finalName: monthName,
      finalYear: year,
      customName: null, // use default period name (month + year)
    );

    // Start new session with same limit and autoRollover enabled
    await startNewSession(
      activeSession.limit,
      autoRollover: true,
    );
  }

  // When user finalizes the session, we update the month details
  @override
  Future<void> finalizeSession({
    required String monthId,
    required String finalName,
    required int finalYear,
    required String? customName,
  }) async {
    final month = _monthBox.get(monthId);
    if (month != null) {
      // create updated month with final details
      final updatedMonth = month.copyWith(
        name: finalName,
        year: finalYear,
        isDraft: false,
        customName: customName,
        totalSpent: getTotalSpent(monthId),
      );

      // save updated month
      await _monthBox.put(month.id, updatedMonth);
    }
  }

  // --- EXPENSE OPERATIONS ---

  @override
  List<Expense> getExpensesForMonth(String monthId) {
    return _expenseBox.values
        .where((expense) => expense.monthId == monthId)
        .toList();
  }

  @override
  List<Expense> getExpensesByMonths(DateTime date) {
    return _expenseBox.values.where((expense) {
      return expense.date.year == date.year && expense.date.month == date.month;
    }).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  @override
  Future<void> updateExpense(Expense updatedExpense) async {
    await _expenseBox.put(updatedExpense.id, updatedExpense);
  }

  // --- CALCULATIONS ---

  @override
  double getTotalSpent(String monthId) {
    return _expenseBox.values
        .where((e) => e.monthId == monthId)
        .fold(0, (sum, item) => sum + item.amount);
  }

  @override
  double getRemainingBudget(String monthId) {
    final month = _monthBox.get(monthId);
    if (month == null) return 0.0;
    final totalSpent = getTotalSpent(monthId);
    return month.limit - totalSpent;
  }

  // --- HISTORY OPERATIONS ---

  @override
  List<Month> getArchivedMonths() {
    final history = _monthBox.values.where((m) => m.isDraft == false).toList();
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }

  @override
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

  // --- DELETE ALL DATA ---
  @override
  Future<void> clearAllData() async {
    await Hive.box<Month>('months').clear();
    await Hive.box<Expense>('expenses').clear();
  }
}
