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
    try {
      final response = await dio.post(
        Endpoints.createPayment,
        data: request.toJson(),
      );

      debugPrint('PAYMENT URL: ${response.realUri}');
      debugPrint('PAYMENT STATUS: ${response.statusCode}');
      debugPrint('PAYMENT RESPONSE: ${response.data}');

      return CreatePaymentResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      debugPrint('PAYMENT ERROR STATUS: ${e.response?.statusCode}');
      debugPrint('PAYMENT ERROR DATA: ${e.response?.data}');

      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception(e.message ?? 'Unable to create payment intent.');
    }
  }
}
