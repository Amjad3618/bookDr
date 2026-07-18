// lib/providers/booking_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Drives the booking wizard: requirements → review & pay → confirmation.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_services.dart';

class BookingProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  bool        _isSubmitting = false;
  bool        _isPaying     = false;
  String?     _errorMessage;
  OrderModel? _createdOrder;

  bool        get isSubmitting => _isSubmitting;
  bool        get isPaying     => _isPaying;
  String?     get errorMessage => _errorMessage;
  OrderModel? get createdOrder => _createdOrder;

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 → 2 : create the order (unpaid) once requirements are submitted
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> createOrder({
    required String patientId,
    required String patientName,
    required String patientImageUrl,
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
    required String gigId,
    required String gigTitle,
    required String packageType,
    required String packageName,
    required double packagePrice,
    required String packageDeliveryTime,
    required List<String> packageFeatures,
    required String requirements,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _service.createOrder(
        patientId: patientId,
        patientName: patientName,
        patientImageUrl: patientImageUrl,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl,
        gigId: gigId,
        gigTitle: gigTitle,
        packageType: packageType,
        packageName: packageName,
        packagePrice: packagePrice,
        packageDeliveryTime: packageDeliveryTime,
        packageFeatures: packageFeatures,
        requirements: requirements,
      );
      _createdOrder = order;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e, st) {
      // ignore: avoid_print
      print('createOrder failed: $e');
      // ignore: avoid_print
      print(st);
      _errorMessage = 'Could not create your booking. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 → 3 : confirm payment
  //
  // ⚠️ PLACEHOLDER — this simulates a successful Stripe payment with a
  // short delay and a fake transaction reference. When Stripe is wired
  // up, replace the body of this method with the block commented out
  // below (or similar), and only invoke _service.markPaid(...) once the
  // gateway confirms success. Nothing in BookingView or OrderService
  // needs to change for that swap.
  //
  // ─── REAL STRIPE FLOW (uncomment once functions/index.js is deployed
  // and `flutter_stripe` + `cloud_functions` are added to pubspec.yaml) ───
  //
  // Future<bool> confirmPayment() async {
  //   if (_createdOrder == null) return false;
  //   _isPaying = true; notifyListeners();
  //   try {
  //     // 1. Ask our Cloud Function to create a PaymentIntent (secret key
  //     //    never leaves the server — see cloud_functions_index.js).
  //     final callable = FirebaseFunctions.instance
  //         .httpsCallable('createPaymentIntent');
  //     final result = await callable.call({
  //       'amount': (_createdOrder!.packagePrice * 100).round(), // paisa
  //       'currency': 'pkr',
  //       'orderId': _createdOrder!.orderId,
  //     });
  //     final clientSecret = result.data['clientSecret'] as String;
  //
  //     // 2. Show Stripe's own payment sheet (card entry, 3-D Secure, etc.)
  //     await stripe.Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: stripe.SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: clientSecret,
  //         merchantDisplayName: 'CareSync',
  //       ),
  //     );
  //     await stripe.Stripe.instance.presentPaymentSheet();
  //
  //     // 3. If we got here without throwing, Stripe confirmed the charge.
  //     await _service.markPaid(
  //       orderId: _createdOrder!.orderId,
  //       paymentMethod: 'stripe',
  //       transactionRef: result.data['paymentIntentId'] as String,
  //     );
  //     _isPaying = false; notifyListeners();
  //     return true;
  //   } on stripe.StripeException catch (e) {
  //     _errorMessage = e.error.localizedMessage ?? 'Payment was cancelled.';
  //     _isPaying = false; notifyListeners();
  //     return false;
  //   } catch (e) {
  //     _errorMessage = 'Payment failed. Please try again.';
  //     _isPaying = false; notifyListeners();
  //     return false;
  //   }
  // }
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> confirmPayment() async {
    if (_createdOrder == null) return false;

    _isPaying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: replace with real Stripe payment flow.
      await Future.delayed(const Duration(seconds: 2));
      final fakeTxnRef =
          'MOCK-${DateTime.now().millisecondsSinceEpoch}';

      await _service.markPaid(
        orderId: _createdOrder!.orderId,
        paymentMethod: 'stripe',
        transactionRef: fakeTxnRef,
      );

      _isPaying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Payment failed. Please try again.';
      _isPaying = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _isSubmitting = false;
    _isPaying     = false;
    _errorMessage = null;
    _createdOrder = null;
  }
}