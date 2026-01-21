import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/repository/hive_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final HiveRepository repository;
  SessionBloc({required this.repository}) : super(SessionLoading()) {
    // event handlers
    on<CheckActiveSession>(_onCheckActiveSession);
    on<StartNewSession>(_onStartNewSession);
    on<AddExpenseEvent>(_onAddExpenseEvent);
    on<DeleteExpenseEvent>(_onDeleteExpenseEvent);
    on<FinalizeSessionEvent>(_onFinalizeSession);
    on<ResetSessionEvent>(_onResetSession);
    on<UpdateSessionLimit>(_onUpdateSessionLimit);

    // check active session when app starts
    add(CheckActiveSession());
  }

  FutureOr<void> _onCheckActiveSession(
    CheckActiveSession event,
    Emitter<SessionState> emit,
  ) {
    // check if the session is active
    try {
      if (repository.getActiveSession() != null) {
        final activeSession = repository.getActiveSession()!;
        final expenses = repository.getExpensesForMonth(activeSession.id);
        final totalSpent = expenses.fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );
        final remainingLimit = activeSession.limit - totalSpent;

        emit(
          SessionActive(
            activeMonth: activeSession,
            expenses: expenses,
            totalSpent: totalSpent,
            remainingLimit: remainingLimit,
          ),
        );
      } else {
        emit(NoActiveSession());
      }
    } catch (e) {
      emit(SessionError('Failed to load active session: $e'));
    }
  }

  FutureOr<void> _onStartNewSession(
    StartNewSession event,
    Emitter<SessionState> emit,
  ) async {
    // start a new session
    try {
      await repository.startNewSession(event.limit);

      // call check active session to refresh state
      add(CheckActiveSession());
    } catch (e) {
      emit(SessionError('Failed to start new session: $e'));
    }
  }

  FutureOr<void> _onAddExpenseEvent(
    AddExpenseEvent event,
    Emitter<SessionState> emit,
  ) async {
    // add expense via repository
    try {
      await repository.addExpense(
        Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          monthId: repository.getActiveSession()!.id,
          title: event.title,
          amount: event.amount,
          date: DateTime.now(),
        ),
      );

      // call check active session to refresh state
      add(CheckActiveSession());
    } catch (e) {
      emit(SessionError('Failed to add expense: $e'));
    }
  }

  FutureOr<void> _onDeleteExpenseEvent(
    DeleteExpenseEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      // delete expense via repository
      await repository.deleteExpense(event.expenseId);

      // call check active session to refresh state
      add(CheckActiveSession());
    } catch (e) {
      emit(SessionError('Failed to delete expense: $e'));
    }
  }

  FutureOr<void> _onFinalizeSession(
    FinalizeSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      // finalize session via repository
      final activeSession = repository.getActiveSession()!;
      await repository.finalizeSession(
        monthId: activeSession.id,
        finalName: event.monthName,
        finalYear: event.year,
        customName: event.customName,
      );

      // emit no active session state
      emit(NoActiveSession());
    } catch (e) {
      emit(SessionError('Failed to finalize session: $e'));
    }
  }

  FutureOr<void> _onResetSession(
    ResetSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    try {
      // reset active session via repository
      await repository.resetActiveSession();

      // emit no active session state
      emit(NoActiveSession());
    } catch (e) {
      emit(SessionError('Failed to reset session: $e'));
    }
  }

  FutureOr<void> _onUpdateSessionLimit(
    UpdateSessionLimit event,
    Emitter<SessionState> emit,
  ) async {
    if (state is SessionActive) {
      try {
        // update session limit via repository
        await repository.updateActiveSessionLimit(event.newLimit);

        // call check active session to refresh state
        add(CheckActiveSession());
      } catch (e) {
        emit(SessionError('Failed to update session limit: $e'));
      }
    }
  }
}
