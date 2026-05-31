// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';
import 'package:froggy_mobile/core/utils/utils.dart';
import 'package:froggy_mobile/main.dart';

class ApiEndpoints {
  static const String API_DOMAIN =
      "https://sandybrown-gerbil-669577.hostingersite.com/";
  static const String API_PREFIX = '${ApiEndpoints.API_DOMAIN}/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_PREFIX,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Auth Endpoints
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String VERIFY_OTP = '/verify-otp';
  static const String RESEND_OTP = '/resend-otp';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String RESET_PASSWORD = '/reset-password';
  static const String LOGOUT = '/logout';

  // Dashboard Endpoints
  static const String DASHBOARD = '/dashboard';

  Future<Map<String, String>> authRequestHeaders() async {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${UserSimplePreferences.getToken()}",
    };
  }

  Future<void> safeSendRequest({
    required Future<Response> Function(Dio dio, Map<String, String> headers)
    request,
    required FutureOr<void> Function(Map<String, dynamic> data) onSuccess,
    FutureOr<void> Function(String error)? onError,
  }) async {
    try {
      final headers = await authRequestHeaders();
      final response = await request(_dio, headers);

      debugPrint(
        "Response status: ${response.statusCode} Body: ${response.data}",
      );

      if ([200, 201].contains(response.statusCode)) {
        if (response.data is Map<String, dynamic>) {
          await onSuccess(response.data);
        } else {
          await onSuccess({});
        }
      }
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");
      debugPrint("Dio response: ${e.response?.data}");

      String errorMsg = "Request failed, please try again later";
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('message')) {
            errorMsg = data['message'].toString();
          } else if (data.containsKey('errors')) {
            // Handle Laravel-style validation errors
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              errorMsg = errors.values.first.toString();
              if (errorMsg.startsWith('[') && errorMsg.endsWith(']')) {
                errorMsg = errorMsg.substring(1, errorMsg.length - 1);
              }
            }
          }
        }
      }

      Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: kWhiteColor,
        fontSize: 17,
        backgroundColor: Colors.red,
      );

      if (onError != null) {
        await onError(errorMsg);
      }

      if (e.response?.statusCode == 401) {
        // Handle unauthenticated globally
        UserSimplePreferences.setToken("");
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      const errorMsg = "Something went wrong!";

      Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: kWhiteColor,
        fontSize: 17,
        backgroundColor: Colors.red,
      );

      if (onError != null) {
        await onError(errorMsg);
      }
    }
  }
}
