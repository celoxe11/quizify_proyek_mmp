part of 'admin_analytics_bloc.dart';

abstract class AdminAnalyticsState {}
class AnalyticsInitial extends AdminAnalyticsState {}
class AnalyticsLoading extends AdminAnalyticsState {}
class AnalyticsLoaded extends AdminAnalyticsState {
  final AdminAnalyticsModel analytics;
  AnalyticsLoaded(this.analytics);
}
class AnalyticsError extends AdminAnalyticsState {
  final String message;
  AnalyticsError(this.message);
}