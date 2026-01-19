part of 'active_session_bloc.dart';

abstract class ActiveSessionEvent extends Equatable {
  const ActiveSessionEvent();

  @override
  List<Object> get props => [];
}

final class CheckActiveSession extends ActiveSessionEvent {}

final class StartNewSession extends ActiveSessionEvent {
  final double limit;
  const StartNewSession(this.limit);

  @override
  List<Object> get props => [limit];
}

final class AddExpenseEvent extends ActiveSessionEvent {
  final String title;
  final double amount;

  const AddExpenseEvent({required this.title, required this.amount});

  @override
  List<Object> get props => [title, amount];
}

final class DeleteExpenseEvent extends ActiveSessionEvent {
  final String expenseId;
  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

final class FinalizeSessionEvent extends ActiveSessionEvent {
  final String monthName;
  final int year;

  const FinalizeSessionEvent({required this.monthName, required this.year});

  @override
  List<Object> get props => [monthName, year];
}
