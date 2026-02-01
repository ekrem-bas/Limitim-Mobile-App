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
    final currentState = state;

    // 1. silent load
    // if we are already in loaded state, do not show loading indicator.
    // just update the focusedMonth of the calendar immediately to prevent UI lag.
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(focusedMonth: month));
    } else {
      // show loader on first load or after an error
      emit(CalendarLoading());
    }

    try {
      // get expenses for previous, current and next month
      final currentMonthExpenses = repository.getExpensesByMonths(month);
      final prevMonth = DateTime(month.year, month.month - 1);
      final prevMonthExpenses = repository.getExpensesByMonths(prevMonth);
      final nextMonth = DateTime(month.year, month.month + 1);
      final nextMonthExpenses = repository.getExpensesByMonths(nextMonth);

      final allVisibleExpenses = [
        ...prevMonthExpenses,
        ...currentMonthExpenses,
        ...nextMonthExpenses,
      ];

      // emit loaded state
      emit(
        CalendarLoaded(
          focusedMonth: month,
          allMonthExpenses: allVisibleExpenses,
          selectedDay: currentState is CalendarLoaded
              ? currentState.selectedDay
              : null,
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
