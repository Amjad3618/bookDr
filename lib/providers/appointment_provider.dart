// lib/providers/appointments_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Backs the "My Appointments" screen — streams the SAME 'orders' collection
// that BookingProvider writes to, so a booking shows up here the instant
// it's created (and its status updates live as the doctor progresses it).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_services.dart';

class AppointmentsProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  List<OrderModel> _orders = [];
  bool             _isLoading = true;
  String?          _errorMessage;
  StreamSubscription<List<OrderModel>>? _sub;

  List<OrderModel> get allOrders   => _orders;
  bool             get isLoading   => _isLoading;
  String?          get errorMessage => _errorMessage;

  /// Booked and either awaiting payment, paid & active, or delivered —
  /// anything that isn't finished yet.
  List<OrderModel> get upcoming => _orders.where((o) =>
      o.status == OrderStatus.pendingPayment ||
      o.status == OrderStatus.active ||
      o.status == OrderStatus.delivered).toList();

  /// Wrapped up, either way.
  List<OrderModel> get completed => _orders.where((o) =>
      o.status == OrderStatus.completed ||
      o.status == OrderStatus.cancelled).toList();

  void startListening(String patientId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.patientOrdersStream(patientId).listen(
      (list) {
        _orders    = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _errorMessage = 'Could not load your appointments. Please try again.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}