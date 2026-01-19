part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

final class LoadHistoryEvent extends HistoryEvent {}

final class DeleteHistoryMonthEvent extends HistoryEvent {
  final String monthId;

  const DeleteHistoryMonthEvent(this.monthId);

  @override
  List<Object> get props => [monthId];
}