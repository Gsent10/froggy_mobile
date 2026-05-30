part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final Map<String, dynamic> userData;
  RegisterRequested(this.userData);
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  final bool isFromRegister;
  VerifyOtpRequested({
    required this.email,
    required this.otp,
    required this.isFromRegister,
  });
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  ResendOtpRequested(this.email);
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

class ResetPasswordRequested extends AuthEvent {
  final String password;
  final String passwordConfirmation;
  ResetPasswordRequested(this.password, this.passwordConfirmation);
}

class LogoutRequested extends AuthEvent {}
