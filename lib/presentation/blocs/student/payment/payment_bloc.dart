import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizify_proyek_mmp/data/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  PaymentBloc(this._repository) : super(const PaymentInitial()) {
    on<CreatePaymentEvent>(_onCreatePayment);
    on<CheckPaymentStatusEvent>(_onCheckPaymentStatus);
    on<FetchPaymentHistoryEvent>(_onFetchPaymentHistory);
    on<CancelPaymentEvent>(_onCancelPayment);
    on<FetchAvatarsEvent>(_onFetchAvatars);
    on<SetActiveAvatarEvent>(_onSetActiveAvatar);
    on<FetchSubscriptionPlansEvent>(_onFetchSubscriptionPlans);
  }

  /// Create payment snap token
  Future<void> _onCreatePayment(
    CreatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    try {
      final snap = await _repository.createPayment(
        type: event.type,
        subscriptionPlanId: event.planId,
        avatarId: event.avatarId,
        amount: event.amount,
      );

      print('✅ [PaymentBloc] Payment snap created: ${snap.orderId}');
      emit(PaymentSnapCreated(snap));
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error creating payment: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Check payment status
  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatusEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentStatusLoading());

    try {
      print('🔄 [PaymentBloc] Checking payment status: ${event.orderId}');

      final status = await _repository.checkPaymentStatus(event.orderId);

      print('✅ [PaymentBloc] Payment status: ${status.status}');
      emit(PaymentStatusLoaded(status));
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error checking payment status: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Fetch payment history
  Future<void> _onFetchPaymentHistory(
    FetchPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentHistoryLoading());

    try {
      print('🔄 [PaymentBloc] Fetching payment history...');

      final payments = await _repository.getPaymentHistory(
        page: event.page,
        limit: event.limit,
      );

      print('✅ [PaymentBloc] Fetched ${payments.length} payment records');
      emit(
        PaymentHistoryLoaded(
          payments: payments,
          currentPage: event.page,
          limit: event.limit,
        ),
      );
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error fetching payment history: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Cancel payment
  Future<void> _onCancelPayment(
    CancelPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      print('🔄 [PaymentBloc] Cancelling payment: ${event.orderId}');

      await _repository.cancelPayment(event.orderId);

      print('✅ [PaymentBloc] Payment cancelled successfully');
      emit(
        const PaymentSuccess(
          message: 'Pembayaran berhasil dibatalkan',
          type: 'cancel',
        ),
      );

      // Emit back to initial state after 1 second
      await Future.delayed(const Duration(seconds: 1));
      emit(const PaymentInitial());
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error cancelling payment: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Fetch avatars
  Future<void> _onFetchAvatars(
    FetchAvatarsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const AvatarLoading());

    try {
      print('🔄 [PaymentBloc] Fetching avatars...');

      final avatars = await _repository.getAvatars();

      print('✅ [PaymentBloc] Fetched ${avatars.length} avatars');
      emit(AvatarLoaded(avatars));
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error fetching avatars: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Set active avatar
  Future<void> _onSetActiveAvatar(
    SetActiveAvatarEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      print('🔄 [PaymentBloc] Setting active avatar: ${event.avatarId}');

      final avatar = await _repository.setActiveAvatar(event.avatarId);

      print('✅ [PaymentBloc] Avatar set as active: ${avatar.name}');
      emit(AvatarSetActive(avatar));

      // Fetch avatars again to update list
      await Future.delayed(const Duration(milliseconds: 500));
      add(const FetchAvatarsEvent());
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error setting active avatar: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }

  /// Fetch subscription plans
  Future<void> _onFetchSubscriptionPlans(
    FetchSubscriptionPlansEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const SubscriptionPlansLoading());

    try {
      print('🔄 [PaymentBloc] Fetching subscription plans...');

      final plans = await _repository.getSubscriptionPlans();

      print('✅ [PaymentBloc] Fetched ${plans.length} subscription plans');
      emit(SubscriptionPlansLoaded(plans));
    } catch (e, stackTrace) {
      print('❌ [PaymentBloc] Error fetching subscription plans: $e');
      print('Stack trace: $stackTrace');
      emit(PaymentError(e.toString()));
    }
  }
}
