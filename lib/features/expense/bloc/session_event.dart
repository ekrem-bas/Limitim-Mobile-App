part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

final class CheckActiveSession extends SessionEvent {}

final class StartNewSession extends SessionEvent {
  final double limit;
  const StartNewSession(this.limit);

  @override
  List<Object> get props => [limit];
}

final class AddExpenseEvent extends SessionEvent {
  final String title;
  final double amount;

  const AddExpenseEvent({required this.title, required this.amount});

  @override
  List<Object> get props => [title, amount];
}

final class DeleteExpenseEvent extends SessionEvent {
  final String expenseId;
  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

final class FinalizeSessionEvent extends SessionEvent {
  final String monthName;
  final int year;

  const FinalizeSessionEvent({required this.monthName, required this.year});

  @override
  List<Object> get props => [monthName, year];
}
