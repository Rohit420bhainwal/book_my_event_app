import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'api_service.dart';

class StripePaymentService {




  static String getCurrencyForCountry(String countryCode) {
    switch (countryCode) {
      case 'IN':
        return 'inr';
      case 'AE':
        return 'aed';
      case 'US':
        return 'usd';
      default:
        return 'usd';
    }
  }


  static Future<void> makePayment(int amount, ApiService apiService) async {
    // 1️⃣ Create payment intent from backend

    final countryCode = ui.PlatformDispatcher.instance.locale.countryCode ?? 'US';
    final currency = getCurrencyForCountry(countryCode);
    print("currency $currency");

    final body = {
      "amount": amount,
      "currency": currency
    };

    final response = await apiService.post("payment/create-payment-intent", body, withAuth: true);

    print("response: $response");
    if(response["success"]){
      var clientSecret = response["data"]["clientSecret"];
      print("clientSecret: $clientSecret");

      // 2️⃣ Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Demo App',
        ),
      );
    }
    // 3️⃣ Present payment sheet
    await Stripe.instance.presentPaymentSheet();
  }
}
