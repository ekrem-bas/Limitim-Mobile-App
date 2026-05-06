part of 'session_bloc.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object> get props => [];
}

final class CheckActiveSession extends SessionEvent {}

final class ResetSessionEvent extends SessionEvent {}

final class UpdateSessionLimit extends SessionEvent {
  final double newLimit;
  final bool autoRollover;
  const UpdateSessionLimit(this.newLimit, {required this.autoRollover});

  @override
  List<Object> get props => [newLimit, autoRollover];
}

final class StartNewSession extends SessionEvent {
  final double limit;
  final bool autoRollover;
  const StartNewSession(this.limit, {this.autoRollover = false});

  @override
  List<Object> get props => [limit, autoRollover];
}

final class AddExpenseEvent extends SessionEvent {
  final String title;
  final double amount;

  const AddExpenseEvent({required this.title, required this.amount});

  @override
  List<Object> get props => [title, amount];
}

final class UpdateExpenseEvent extends SessionEvent {
  final Expense updatedExpense;
  const UpdateExpenseEvent(this.updatedExpense);

  @override
  List<Object> get props => [updatedExpense];
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
  final String? customName;

  const FinalizeSessionEvent({
    required this.monthName,
    required this.year,
    this.customName,
  });

  @override
  List<Object> get props => [monthName, year];
}

/// Triggered when 30-day auto-rollover period has elapsed
final class AutoRolloverTriggered extends SessionEvent {}
