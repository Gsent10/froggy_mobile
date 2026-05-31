part of 'topup_bloc.dart';

abstract class TopupEvent {}

class SubmitTopup extends TopupEvent {
  final String currencyCode;
  final double amount;
  final String paymentMethod;
  final String idempotencyKey;

  SubmitTopup({
    required this.currencyCode,
    required this.amount,
    required this.paymentMethod,
    required this.idempotencyKey,
  });
}

class ResetTopup extends TopupEvent {}
