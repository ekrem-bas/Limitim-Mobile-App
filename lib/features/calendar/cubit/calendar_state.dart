part of 'calendar_cubit.dart';

sealed class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object> get props => [];
}

final class CalendarInitial extends CalendarState {}

final class CalendarLoading extends CalendarState {}

final class CalendarLoaded extends CalendarState {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final List<Expense> allMonthExpenses;

  const CalendarLoaded({
    required this.focusedMonth,
    this.selectedDay,
    required this.allMonthExpenses,
  });

  @override
  List<Object> get props => [focusedMonth, selectedDay ?? '', allMonthExpenses];

  CalendarLoaded copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
    List<Expense>? allMonthExpenses,
  }) {
    return CalendarLoaded(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay:
          selectedDay, // allow null to deselect day (?? this.selectedDay removed)
      allMonthExpenses: allMonthExpenses ?? this.allMonthExpenses,
    );
  }

  // get expenses for focused month
  List<Expense> get visibleExpenses {
    final filtered = selectedDay == null
        ? allMonthExpenses
        : allMonthExpenses
              .where((e) => isSameDay(e.date, selectedDay!))
              .toList();

    // sort by date descending
    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }

  // visible dots for days with expenses
  Map<DateTime, List<Expense>> get eventMarkers {
    final Map<DateTime, List<Expense>> data = {};
    for (var expense in allMonthExpenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (data[date] == null) data[date] = [];
      data[date]!.add(expense);
    }
    return data;
  }

  bool get isEmptySelectedDay => selectedDay != null && visibleExpenses.isEmpty;
}

final class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object> get props => [message];
}
