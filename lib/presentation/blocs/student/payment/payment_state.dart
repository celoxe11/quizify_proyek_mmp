import 'package:equatable/equatable.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/models/payment_snap_model.dart';
import 'package:quizify_proyek_mmp/data/models/payment_status_model.dart';
import 'package:quizify_proyek_mmp/data/models/subscription_model.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

// Payment Creation States
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSnapCreated extends PaymentState {
  final PaymentSnapModel snap;

  const PaymentSnapCreated(this.snap);

  @override
  List<Object?> get props => [snap];
}

// Payment Status States
class PaymentStatusLoading extends PaymentState {
  const PaymentStatusLoading();
}

class PaymentStatusLoaded extends PaymentState {
  final PaymentStatusModel status;

  const PaymentStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

// Payment History States
class PaymentHistoryLoading extends PaymentState {
  const PaymentHistoryLoading();
}

class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentStatusModel> payments;
  final int currentPage;
  final int limit;

  const PaymentHistoryLoaded({
    required this.payments,
    this.currentPage = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [payments, currentPage, limit];
}

// Avatar States
class AvatarLoading extends PaymentState {
  const AvatarLoading();
}

class AvatarLoaded extends PaymentState {
  final List<AvatarModel> avatars;

  const AvatarLoaded(this.avatars);

  @override
  List<Object?> get props => [avatars];
}

class AvatarSetActive extends PaymentState {
  final AvatarModel avatar;

  const AvatarSetActive(this.avatar);

  @override
  List<Object?> get props => [avatar];
}

// Subscription Plans States
class SubscriptionPlansLoading extends PaymentState {
  const SubscriptionPlansLoading();
}

class SubscriptionPlansLoaded extends PaymentState {
  final List<SubscriptionModel> plans;

  const SubscriptionPlansLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

// Error State
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Success State
class PaymentSuccess extends PaymentState {
  final String message;
  final String type; // 'subscription', 'avatar', 'cancel', etc

  const PaymentSuccess({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}
