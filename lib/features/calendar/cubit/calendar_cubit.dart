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
  void loadMonth(DateTime month) async {
    emit(CalendarLoading());
    try {
      final expenses = repository.getExpensesByMonths(month);
      emit(
        CalendarLoaded(
          focusedMonth: month,
          allMonthExpenses: expenses,
          selectedDay: null, // no day selected initially
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
