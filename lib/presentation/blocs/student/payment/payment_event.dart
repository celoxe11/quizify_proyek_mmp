import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentEvent extends PaymentEvent {
  final String type; // 'subscription' or 'avatar'
  final String? planId;
  final String? avatarId;

  const CreatePaymentEvent({
    required this.type,
    this.planId,
    this.avatarId,
  });

  @override
  List<Object?> get props => [type, planId, avatarId];
}

class CheckPaymentStatusEvent extends PaymentEvent {
  final String orderId;

  const CheckPaymentStatusEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FetchPaymentHistoryEvent extends PaymentEvent {
  final int page;
  final int limit;

  const FetchPaymentHistoryEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class CancelPaymentEvent extends PaymentEvent {
  final String orderId;

  const CancelPaymentEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class FetchAvatarsEvent extends PaymentEvent {
  const FetchAvatarsEvent();
}

class SetActiveAvatarEvent extends PaymentEvent {
  final String avatarId;

  const SetActiveAvatarEvent(this.avatarId);

  @override
  List<Object?> get props => [avatarId];
}

class FetchSubscriptionPlansEvent extends PaymentEvent {
  final String userId;

  const FetchSubscriptionPlansEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
