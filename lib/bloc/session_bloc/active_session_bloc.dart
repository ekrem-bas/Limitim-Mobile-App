import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/repository/expense_repository.dart';

part 'active_session_event.dart';
part 'active_session_state.dart';

class ActiveSessionBloc extends Bloc<ActiveSessionEvent, ActiveSessionState> {
  final ExpenseRepository repository;
  ActiveSessionBloc({required this.repository}) : super(SessionLoading()) {
    // event handlers
    on<CheckActiveSession>(_onCheckActiveSession);
    on<StartNewSession>(_onStartNewSession);
    on<AddExpenseEvent>(_onAddExpenseEvent);
    on<DeleteExpenseEvent>(_onDeleteExpenseEvent);
    on<FinalizeSessionEvent>(_onFinalizeSession);

    // check active session when app starts
    add(CheckActiveSession());
  }

  FutureOr<void> _onCheckActiveSession(
    CheckActiveSession event,
    Emitter<ActiveSessionState> emit,
  ) {
    // check if the session is active
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
  }

  FutureOr<void> _onStartNewSession(
    StartNewSession event,
    Emitter<ActiveSessionState> emit,
  ) async {
    // start a new session
    await repository.startNewSession(event.limit);

    // call check active session to refresh state
    add(CheckActiveSession());
  }

  FutureOr<void> _onAddExpenseEvent(
    AddExpenseEvent event,
    Emitter<ActiveSessionState> emit,
  ) async {
    // add expense via repository
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
  }

  FutureOr<void> _onDeleteExpenseEvent(
    DeleteExpenseEvent event,
    Emitter<ActiveSessionState> emit,
  ) async {
    // delete expense via repository
    await repository.deleteExpense(event.expenseId);

    // call check active session to refresh state
    add(CheckActiveSession());
  }

  FutureOr<void> _onFinalizeSession(
    FinalizeSessionEvent event,
    Emitter<ActiveSessionState> emit,
  ) async {
    // finalize session via repository
    final activeSession = repository.getActiveSession()!;
    await repository.finalizeSession(
      monthId: activeSession.id,
      finalName: event.monthName,
      finalYear: event.year,
    );

    // emit no active session state
    emit(NoActiveSession());
  }
}
