import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:heimdall_flutter/secret/stripe_key.dart';
import 'dart:convert';

final stripePaymentProvider = Provider((ref) => StripePaymentService());

class StripePaymentService {
  Future<void> initPaymentSheet({
    required String amount,
    required String currency,
    required String merchantName,
    String? description, // opcional
  }) async {
    try {
      final paymentIntent = await _createPaymentIntent(
        amount,
        currency,
        description: description,
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: merchantName,
          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }

  Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency, {
    String? description, // opcional
  }) async {
    final body = {
      'amount': (int.parse(amount) * 100).toString(), // Stripe usa centavos
      'currency': currency,
      'payment_method_types[]': 'card',
    };
    // Agregar descripción si se proporcionó
    if (description != null) {
      body['description'] = description;
    }

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error al crear PaymentIntent: ${response.statusCode} ${response.body}',
      );
    }
  }
}
