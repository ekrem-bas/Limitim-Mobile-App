part of 'expense_detail_cubit.dart';

sealed class ExpenseDetailState extends Equatable {
  const ExpenseDetailState();

  @override
  List<Object> get props => [];
}

final class ExpenseDetailInitial extends ExpenseDetailState {}

final class ExpenseDetailLoading extends ExpenseDetailState {}

final class ExpenseDetailUpdated extends ExpenseDetailState {}

final class ExpenseDetailError extends ExpenseDetailState {
  final String message;
  const ExpenseDetailError(this.message);
}
