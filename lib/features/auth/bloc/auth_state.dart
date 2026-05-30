part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpRequired,
  otpVerified,
  error,
}

@immutable
class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? email; // To persist email during OTP flow
  final bool isFromRegister;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.email,
    this.isFromRegister = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? email,
    bool? isFromRegister,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      email: email ?? this.email,
      isFromRegister: isFromRegister ?? this.isFromRegister,
    );
  }
}

class AuthInitial extends AuthState {}
