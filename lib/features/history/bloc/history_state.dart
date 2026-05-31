part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, error }

@immutable
final class HistoryState {
  final HistoryStatus transactionsStatus;
  final List<Activity> transactions;
  final String transactionsError;

  final HistoryStatus activityStatus;
  final List<Log> activity;
  final String activityError;

  const HistoryState({
    this.transactionsStatus = HistoryStatus.initial,
    this.transactions = const [],
    this.transactionsError = '',
    this.activityStatus = HistoryStatus.initial,
    this.activity = const [],
    this.activityError = '',
  });

  HistoryState copyWith({
    HistoryStatus? transactionsStatus,
    List<Activity>? transactions,
    String? transactionsError,
    HistoryStatus? activityStatus,
    List<Log>? activity,
    String? activityError,
  }) {
    return HistoryState(
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactions: transactions ?? this.transactions,
      transactionsError: transactionsError ?? this.transactionsError,
      activityStatus: activityStatus ?? this.activityStatus,
      activity: activity ?? this.activity,
      activityError: activityError ?? this.activityError,
    );
  }
}
