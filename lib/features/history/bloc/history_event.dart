part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

final class FetchTransactions extends HistoryEvent {}

final class FetchActivity extends HistoryEvent {}
