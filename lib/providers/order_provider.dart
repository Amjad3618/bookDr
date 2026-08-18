// lib/providers/order_provider.dart  ·  PATIENT APP
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
  // up, replace the body of this method with the real SDK/API call, and
  // only invoke _service.markPaid(...) once the gateway confirms success.
  // Nothing in BookingView or OrderService needs to change for that swap
  // (markPaid's signature already matches what a real gateway confirmation
  // would give you — just swap where transactionRef comes from).
  //
  // NOTE: markPaid also computes and stores `deliveryDeadline` — that's
  // what powers the countdown timer on both apps. Whatever replaces this
  // mock still needs to pass `packageDeliveryTime` through unchanged.
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
        packageDeliveryTime: _createdOrder!.packageDeliveryTime,
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