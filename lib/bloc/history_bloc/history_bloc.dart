import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/repository/expense_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ExpenseRepository repository;

  HistoryBloc({required this.repository}) : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteHistoryMonthEvent>(_onDeleteHistoryMonth);
  }

  FutureOr<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryInitial());

    try {
      // get archived months from repository
      final archivedMonths = repository.getArchivedMonths();
      if (archivedMonths.isEmpty) {
        emit(HistoryEmpty());
      } else {
        emit(HistoryLoaded(archivedMonths));
      }
    } catch (e) {
      emit(HistoryError("Failed to load history: $e"));
    }
  }

  FutureOr<void> _onDeleteHistoryMonth(
    DeleteHistoryMonthEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      // delete month from repository
      await repository.deleteArchivedMonth(event.monthId);

      // reload history after deletion
      add(LoadHistoryEvent());
    } catch (e) {
      emit(HistoryError("Failed to delete month: $e"));
    }
  }
}
