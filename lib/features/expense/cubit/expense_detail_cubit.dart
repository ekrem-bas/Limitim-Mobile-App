import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/repository/hive_repository.dart';

part 'expense_detail_state.dart';

class ExpenseDetailCubit extends Cubit<ExpenseDetailState> {
  final HiveRepository repository;
  ExpenseDetailCubit(this.repository) : super(ExpenseDetailInitial());

  // update expense
  Future<void> updateExpense(Expense updatedExpense) async {
    emit(ExpenseDetailLoading());

    try {
      await repository.updateExpense(updatedExpense);
      emit(ExpenseDetailUpdated());
    } catch (e) {
      emit(ExpenseDetailError('Failed to update expense: $e'));
    }
  }

  // delete expense
  Future<bool> deleteExpense(String id) async {
    emit(ExpenseDetailLoading());
    try {
      await repository.deleteExpense(id);
      return true;
    } catch (e) {
      emit(ExpenseDetailError('Failed to delete expense: $e'));
      return false;
    }
  }
}
