import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/repository/hive_repository.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final HiveRepository repository;
  CalendarCubit(this.repository) : super(CalendarInitial());

  // load expenses for the focused month (first load or month change)
  // but to ensure visibility when switching months, we load 3 months of data:
  // previous month, current month, next month
  void loadMonth(DateTime month) async {
    emit(CalendarLoading());
    try {
      // to ensure visibility when switching months, we load 3 months of data:
      // current month, previous month, and next month
      final currentMonthExpenses = repository.getExpensesByMonths(month);

      // calculate previous month
      final prevMonth = DateTime(month.year, month.month - 1);
      final prevMonthExpenses = repository.getExpensesByMonths(prevMonth);

      // calculate next month
      final nextMonth = DateTime(month.year, month.month + 1);
      final nextMonthExpenses = repository.getExpensesByMonths(nextMonth);

      // combine all lists
      final allVisibleExpenses = [
        ...prevMonthExpenses,
        ...currentMonthExpenses,
        ...nextMonthExpenses,
      ];

      emit(
        CalendarLoaded(
          focusedMonth: month,
          allMonthExpenses: allVisibleExpenses,
          selectedDay: null,
        ),
      );
    } catch (e) {
      emit(CalendarError("Veriler yüklenemedi: $e"));
    }
  }

  // select/deselect a day
  void toggleDaySelection(DateTime day) {
    if (state is CalendarLoaded) {
      final currentState = state as CalendarLoaded;
      if (isSameDay(currentState.selectedDay, day)) {
        // already selected -> deselect
        emit(currentState.copyWith(selectedDay: null));
      } else {
        // newly selected day -> filter
        emit(currentState.copyWith(selectedDay: day));
      }
    }
  }
}
