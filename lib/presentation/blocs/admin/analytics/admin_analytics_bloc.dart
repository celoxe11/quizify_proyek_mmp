import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../domain/repositories/admin_repository.dart';
import '../../../../../data/models/admin_analytics_model.dart';

part 'admin_analytics_event.dart';
part 'admin_analytics_state.dart';

class AdminAnalyticsBloc extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final AdminRepository repository;

  AdminAnalyticsBloc(this.repository) : super(AnalyticsInitial()) {
    on<LoadAnalytics>((event, emit) async {
      emit(AnalyticsLoading());
      try {
        final data = await repository.fetchAnalytics();
        emit(AnalyticsLoaded(data));
      } catch (e) {
        emit(AnalyticsError(e.toString()));
      }
    });
  }
}