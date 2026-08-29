import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static final Map<String, PaymentPlan> plans = {
    'basic': PaymentPlan(
      id: 'basic',
      name: 'Basic',
      priceUsd: AppConstants.basicSubscriptionPrice,
      type: SubscriptionType.basic,
      durationDays: 30,
      description: 'Ad-free + Blue checkmark',
    ),
    'premium': PaymentPlan(
      id: 'premium',
      name: 'Premium',
      priceUsd: AppConstants.premiumPrice,
      type: SubscriptionType.fanPremium,
      durationDays: 30,
      description: '2-week premium celebrity posts + Green checkmark',
    ),
    'celebrity': PaymentPlan(
      id: 'celebrity',
      name: 'Celebrity',
      priceUsd: AppConstants.celebrityPrice,
      type: SubscriptionType.celebrityPremium,
      durationDays: 365,
      description: 'Path to Red Verified Celebrity checkmark',
    ),
  };

  Future<PaymentResult> purchaseWithStripe({
    required String planId,
    required String userId,
  }) async {
    final plan = plans[planId];
    if (plan == null) {
      return PaymentResult(success: false, message: 'Invalid plan');
    }

    try {
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amountUsd': plan.priceUsd,
        'planId': planId,
        'currency': 'usd',
      });

      final clientSecret = result.data['clientSecret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tikki',
          style: ThemeMode.dark,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(
        success: true,
        message: '${plan.name} payment successful!',
        plan: plan,
        transactionId: result.data['paymentIntentId'],
      );
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: e.error.localizedMessage ?? 'Payment cancelled',
      );
    } catch (e) {
      return PaymentResult(success: false, message: e.toString());
    }
  }

  Future<PaymentResult> purchaseWithPaystack({
    required String planId,
    required String userId,
    required String email,
  }) async {
    final plan = plans[planId];
    if (plan == null) {
      return PaymentResult(success: false, message: 'Invalid plan');
    }

    try {
      final callable = _functions.httpsCallable('initializePaystackTransaction');
      final result = await callable.call({
        'amountUsd': plan.priceUsd,
        'planId': planId,
        'email': email,
        'userId': userId,
      });

      final authorizationUrl = result.data['authorizationUrl'] as String?;
      final reference = result.data['reference'] as String?;

      if (authorizationUrl == null) {
        return PaymentResult(success: false, message: 'Failed to initialize Paystack');
      }

      return PaymentResult(
        success: true,
        message: 'Redirect to Paystack',
        plan: plan,
        transactionId: reference,
        redirectUrl: authorizationUrl,
      );
    } catch (e) {
      return PaymentResult(success: false, message: e.toString());
    }
  }

  Future<PaymentResult> requestPayout({
    required double amount,
    String method = 'bank',
  }) async {
    try {
      final callable = _functions.httpsCallable('requestPayout');
      final result = await callable.call({
        'amount': amount,
        'method': method,
      });

      return PaymentResult(
        success: true,
        message: result.data['message'] ?? 'Payout requested',
        transactionId: result.data['payoutId'],
      );
    } catch (e) {
      return PaymentResult(success: false, message: e.toString());
    }
  }
}

class PaymentPlan {
  final String id;
  final String name;
  final double priceUsd;
  final SubscriptionType type;
  final int durationDays;
  final String description;

  PaymentPlan({
    required this.id,
    required this.name,
    required this.priceUsd,
    required this.type,
    required this.durationDays,
    required this.description,
  });
}

class PaymentResult {
  final bool success;
  final String message;
  final PaymentPlan? plan;
  final String? transactionId;
  final String? redirectUrl;

  PaymentResult({
    required this.success,
    required this.message,
    this.plan,
    this.transactionId,
    this.redirectUrl,
  });
}
