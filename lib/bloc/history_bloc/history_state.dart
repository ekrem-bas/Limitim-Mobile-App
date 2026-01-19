part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

final class HistoryInitial extends HistoryState {}

final class HistoryEmpty extends HistoryState {}

final class HistoryLoaded extends HistoryState {
  final List<Month> archivedMonths;

  const HistoryLoaded(this.archivedMonths);

  @override
  List<Object> get props => [archivedMonths];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}
