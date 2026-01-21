part of 'session_bloc.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object> get props => [];
}

final class SessionLoading extends SessionState {}

final class NoActiveSession extends SessionState {}

final class SessionActive extends SessionState {
  final Month activeMonth;
  final List<Expense> expenses;
  final double totalSpent;
  final double remainingLimit;

  const SessionActive({
    required this.activeMonth,
    required this.expenses,
    required this.totalSpent,
    required this.remainingLimit,
  });

  @override
  List<Object> get props => [activeMonth, expenses, totalSpent, remainingLimit];
}

final class SessionError extends SessionState {
  final String message;
  const SessionError(this.message);

  @override
  List<Object> get props => [message];
}
