import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase;

  PaymentService(this._supabase);

  Future<void> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      // 1. Call Edge Function to get client secret
      final response = await _supabase.functions.invoke('create-payment-intent', body: {
        'amount': (amount * 100).toInt(), // Cents
        'currency': currency,
      });

      final clientSecret = response.data['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Failed to get client secret');
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Who's Got What",
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      
      // Payment successful
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}
