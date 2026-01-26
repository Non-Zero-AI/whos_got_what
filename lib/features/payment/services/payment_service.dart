import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentService {
  final SupabaseClient _supabase;

  PaymentService(this._supabase);

  Future<void> processPayment({
    required double amount,
    required String currency,
  }) async {
    if (!kIsWeb && Platform.isIOS) {
      await _processAppleIAP(amount);
    } else {
      await _processStripe(amount, currency);
    }
  }

  Future<void> _processStripe(double amount, String currency) async {
    try {
      // 1. Call Edge Function to get client secret
      final response = await _supabase.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': (amount * 100).toInt(), // Cents
          'currency': currency,
        },
      );

      final clientSecret = response.data['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Failed to get client secret');
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Streetside Local',
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _processAppleIAP(double amount) async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      throw Exception('In-App Purchases are not available on this device');
    }

    // In-App Purchase implementation logic would go here
    // Note: requires setting up product IDs in App Store Connect
    // For now, providing a placeholder that indicates IAP is routed
    print('Processing Apple IAP for amount: $amount');
  }
}
