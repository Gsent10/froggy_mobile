import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:froggy_mobile/core/network/api_endpoints.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiEndpoints _apiEndpoints = ApiEndpoints();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Email and password cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.LOGIN,
        data: {'email': event.email, 'password': event.password},
        options: Options(headers: headers),
      ),
      onSuccess: (data) async {
        final token = data['token'];
        if (token != null) {
          await UserSimplePreferences.setToken(token);
          emit(state.copyWith(status: AuthStatus.authenticated));
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.error,
              errorMessage: 'Token not found',
            ),
          );
        }
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.userData['full_name'].isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Full name field cannot be empty',
        ),
      );
      return;
    }

    if (event.userData['email'].isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Email field cannot be empty',
        ),
      );
      return;
    }

    if (event.userData['phone_number'].isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Phone number field cannot be empty',
        ),
      );
      return;
    }

    if (event.userData['password'].isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Password field cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.REGISTER,
        data: event.userData,
        options: Options(headers: headers),
      ),
      onSuccess: (data) {
        emit(
          state.copyWith(
            status: AuthStatus.otpRequired,
            email: event.userData['email'],
            isFromRegister: true,
          ),
        );
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.otp.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'OTP field cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.VERIFY_OTP,
        data: {'email': event.email, 'otp': event.otp},
        options: Options(headers: headers),
      ),
      onSuccess: (data) async {
        if (event.isFromRegister) {
          // If from register, we might get a token immediately or need to login
          final token = data['token'];
          if (token != null) {
            await UserSimplePreferences.setToken(token);
            emit(state.copyWith(status: AuthStatus.authenticated));
          } else {
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          }
        } else {
          // If from forgot password, proceed to reset password
          final token = data['token'];
          if (token != null) {
            await UserSimplePreferences.setToken(token);
          }
          emit(state.copyWith(status: AuthStatus.otpVerified));
        }
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Email cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.RESEND_OTP,
        data: {'email': event.email},
        options: Options(headers: headers),
      ),
      onSuccess: (data) {
        emit(
          state.copyWith(
            status: AuthStatus.otpRequired,
            email: event.email,
            isFromRegister: true,
          ),
        );
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Email cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.FORGOT_PASSWORD,
        data: {'email': event.email},
        options: Options(headers: headers),
      ),
      onSuccess: (data) {
        emit(
          state.copyWith(
            status: AuthStatus.otpRequired,
            email: event.email,
            isFromRegister: false,
          ),
        );
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.failed,
          errorMessage: 'Password cannot be empty',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) => dio.post(
        ApiEndpoints.RESET_PASSWORD,
        data: {
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
        },
        options: Options(headers: headers),
      ),
      onSuccess: (data) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      },
      onError: (error) =>
          emit(state.copyWith(status: AuthStatus.error, errorMessage: error)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _apiEndpoints.safeSendRequest(
      request: (dio, headers) =>
          dio.post(ApiEndpoints.LOGOUT, options: Options(headers: headers)),
      onSuccess: (data) async {
        await UserSimplePreferences.setToken('');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      },
    );
  }
}
