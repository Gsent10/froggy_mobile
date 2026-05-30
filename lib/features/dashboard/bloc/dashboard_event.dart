part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class TabChanged extends DashboardEvent {
  final int index;
  TabChanged(this.index);
}
