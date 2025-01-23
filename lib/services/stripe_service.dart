import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../const.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<Map<String, dynamic>?> makePayment(int amount) async {
    print('Starting payment process...');
    try {
      var paymentIntentClientSecret = await _createPaymentIntent(
        amount,
        "INR",
      );
      if (paymentIntentClientSecret == null) {
        print('Failed to create payment intent');
        return null;
      }

      print('Payment Intent Client Secret: $paymentIntentClientSecret');

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Bobby Butcher",
        ),
      );
      print('Payment sheet initialized.');

      // Process payment and return details
      return await _processPayment(paymentIntentClientSecret, amount);
    } catch (e) {
      print('Error in payment flow: $e');
      return null;
    }
  }


  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "metadata": {
          "order_id": "ORDER_${DateTime.now().millisecondsSinceEpoch}"
        }
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('Payment Intent Response: ${response.data}');
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print('Error creating payment intent: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _processPayment(
      String paymentIntentClientSecret, int amount) async {
    try {
      print('Initializing payment sheet...');
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet presented successfully.');
      return {
        'paymentId': paymentIntentClientSecret.split('_secret')[0],
        'orderId': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
        'paymentTimestamp': DateTime.now().toIso8601String(),
        'amount': amount,
      };
      print('Confirming payment...');
      await Stripe.instance.confirmPaymentSheetPayment();
      print({
            'paymentId': paymentIntentClientSecret.split('_secret')[0],
            'orderId': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
            'paymentTimestamp': DateTime.now().toIso8601String(),
            'amount': amount,
          });
      print('Payment confirmed!');
    } catch (e) {
      print('Error during payment process: $e');
      if (e is StripeException) {
        print('Stripe error: ${e.error.localizedMessage}');
      }
    }

    // try {
    //   await Stripe.instance.presentPaymentSheet();
    //   print('After Payment Gateway');
    //   await Stripe.instance.confirmPaymentSheetPayment();
    //
    //   print('Payment confirmed.');
    //   print({
    //     'paymentId': paymentIntentClientSecret.split('_secret')[0],
    //     'orderId': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
    //     'paymentTimestamp': DateTime.now().toIso8601String(),
    //     'amount': amount,
    //   });
    //   return {
    //     'paymentId': paymentIntentClientSecret.split('_secret')[0],
    //     'orderId': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
    //     'paymentTimestamp': DateTime.now().toIso8601String(),
    //     'amount': amount,
    //   };
    // } catch (e) {
    //   print('Error processing payment: $e');
    //   return null;
    // }
  }


  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}



