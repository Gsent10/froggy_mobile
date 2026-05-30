// ignore_for_file: constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:froggy_mobile/core/utils/user_simple_preferences.dart';
import 'package:froggy_mobile/core/utils/utils.dart';

class ApiEndpoints {
  static const String API_DOMAIN =
      "https://xxxxxxxxx.com"; // Input actual domain
  static const String API_PREFIX = '${ApiEndpoints.API_DOMAIN}/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_PREFIX,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, String>> authRequestHeaders() async {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${UserSimplePreferences.getToken()}",
    };
  }

  Future<void> safeSendRequest(
    Future<Response> Function(Dio dio, Map<String, String> headers) mainRequest,
    String? Function(Map<String, dynamic> response) handleSuccess,
  ) async {
    try {
      final headers = await authRequestHeaders();
      final response = await mainRequest(_dio, headers);

      debugPrint(
        "Response status: ${response.statusCode} Body: ${response.data}",
      );

      if ([200, 201].contains(response.statusCode)) {
        if (response.data is Map<String, dynamic>) {
          String? operationMessage = handleSuccess(response.data);
          debugPrint("Response body: $operationMessage");
        }
      }
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");

      if (e.response?.statusCode == 401) {
        throw Exception('Unauthenticated');
      }

      String errorMsg = "Request failed, please try again later";
      if (e.response?.data != null) {
        errorMsg = e.response?.data["message"]?.toString() ?? errorMsg;
      }

      Fluttertoast.showToast(
        msg: errorMsg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: kWhiteColor,
        fontSize: 17,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception('Something went wrong!');
    }
  }
}
