part of 'active_session_bloc.dart';

abstract class ActiveSessionState extends Equatable {
  const ActiveSessionState();

  @override
  List<Object> get props => [];
}

final class SessionLoading extends ActiveSessionState {}

final class NoActiveSession extends ActiveSessionState {}

final class SessionActive extends ActiveSessionState {
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

final class SessionError extends ActiveSessionState {
  final String message;
  const SessionError(this.message);

  @override
  List<Object> get props => [message];
}
