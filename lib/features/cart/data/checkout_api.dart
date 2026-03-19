import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/api/endpoints.dart';
import '../models/checkout_payment_models.dart';

class CheckoutApi {
  final Dio dio;

  CheckoutApi(this.dio);

  Future<CreatePaymentResponse> createPaymentIntent(
    CreatePaymentRequest request,
  ) async {
    final response = await dio.post(
      Endpoints.createPayment,
      data: request.toJson(),
    );

    debugPrint('REAL URL: ${response.realUri}');
    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('RESPONSE DATA: ${response.data}');

    if (response.data is String &&
        (response.data as String).contains('<!DOCTYPE html>')) {
      throw Exception(
        'API returned HTML instead of JSON. Check baseUrl/API routing.',
      );
    }

    return CreatePaymentResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<Map<String, dynamic>> fetchOrder(int orderId) async {
    final response = await dio.get('v1/orders/$orderId');

    debugPrint('ORDER URL: ${response.realUri}');
    debugPrint('ORDER STATUS: ${response.statusCode}');
    debugPrint('ORDER RESPONSE DATA: ${response.data}');

    if (response.data is String &&
        (response.data as String).contains('<!DOCTYPE html>')) {
      throw Exception(
        'API returned HTML instead of JSON when fetching order. Check baseUrl/API routing.',
      );
    }

    return Map<String, dynamic>.from(response.data as Map);
  }
}
