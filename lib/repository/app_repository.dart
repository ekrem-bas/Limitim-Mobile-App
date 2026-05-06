import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/models/month.dart';

/// Abstract repository interface for the app's data operations.
/// Concrete implementations (e.g. HiveRepository) should implement this.
abstract class AppRepository {
  // --- SESSION (DRAFT) MANAGEMENT ---

  /// Returns the active spending session, or null if none exists.
  Month? getActiveSession();

  /// Start a new session with the given limit.
  Future<void> startNewSession(double limit, {bool autoRollover = false});

  /// Delete the active session and all its expenses.
  Future<void> resetActiveSession();

  /// Update the limit of the active session.
  Future<void> updateActiveSessionLimit(double newLimit);

  /// Update the auto-rollover setting of the active session.
  Future<void> updateAutoRollover(bool autoRollover);

  /// Auto-rollover: finalize current session with month name and start new one.
  Future<void> autoRolloverSession();

  /// Finalize the session with final details (archive it).
  Future<void> finalizeSession({
    required String monthId,
    required String finalName,
    required int finalYear,
    required String? customName,
  });

  // --- EXPENSE OPERATIONS ---

  /// Get all expenses for a given month.
  List<Expense> getExpensesForMonth(String monthId);

  /// Get all expenses for a given calendar month.
  List<Expense> getExpensesByMonths(DateTime date);

  /// Add a new expense.
  Future<void> addExpense(Expense expense);

  /// Delete an expense by its ID.
  Future<void> deleteExpense(String id);

  /// Update an existing expense.
  Future<void> updateExpense(Expense updatedExpense);

  // --- CALCULATIONS ---

  /// Get total spent for a given month.
  double getTotalSpent(String monthId);

  /// Get remaining budget for a given month.
  double getRemainingBudget(String monthId);

  // --- HISTORY OPERATIONS ---

  /// Get all archived (finalized) months, sorted by newest first.
  List<Month> getArchivedMonths();

  /// Delete an archived month and all its expenses.
  Future<void> deleteArchivedMonth(String monthId);

  // --- DELETE ALL DATA ---

  /// Clear all data (months and expenses).
  Future<void> clearAllData();
}
