import 'package:hive/hive.dart';
import '../models/month.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Box<Month> get _monthBox => Hive.box<Month>('months');
  Box<Expense> get _expenseBox => Hive.box<Expense>('expenses');

  // --- OTURUM (TASLAK) YÖNETİMİ ---

  // Şu an aktif bir harcama oturumu (limit belirlenmiş mi) var mı?
  Month? getActiveSession() {
    try {
      return _monthBox.values.firstWhere((month) => month.isDraft == true);
    } catch (e) {
      return null; // Eğer taslak yoksa null döner (State 1: Limit İste)
    }
  }

  // Yeni oturum başlat (Kullanıcı limit belirlediğinde)
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

  // Oturumu kapat ve geçmişe kaydet (Kullanıcı "Kaydet" dediğinde)
  Future<void> finalizeSession({
    required String monthId,
    required String finalName,
    required int finalYear,
  }) async {
    final month = _monthBox.get(monthId);
    if (month != null) {
      month.name = finalName;
      month.year = finalYear;
      month.isDraft = false; // Artık geçmişe gitti
      await _monthBox.put(month.id, month);
    }
  }

  // --- HARCAMA İŞLEMLERİ ---

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

  // --- HESAPLAMALAR ---

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

  // --- GEÇMİŞ ---

  List<Month> getHistory() {
    final history = _monthBox.values.where((m) => m.isDraft == false).toList();
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return history;
  }
}
