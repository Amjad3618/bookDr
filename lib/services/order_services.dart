// lib/services/order_service.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Handles Firestore reads/writes for the 'orders' collection.
//
// PAYMENT NOTE: `createOrder()` currently marks the order paymentStatus as
// 'pending' and status as 'pendingPayment'. The booking flow calls
// `mockConfirmPayment()` right after — that's a PLACEHOLDER standing in for
// the real Stripe flow. When Stripe is wired up, replace the call in
// BookingProvider.confirmPayment() with the real gateway round-trip, then
// call `markPaid()` with the real transactionRef on success. Nothing else
// in this file needs to change.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection('orders');

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE ORDER
  // ══════════════════════════════════════════════════════════════════════════

  Future<OrderModel> createOrder({
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
    final ref = _orders.doc(); // auto id — also used as videoCallChannelId

    final data = {
      'participantIds': [patientId, doctorId],
      'patientId':       patientId,
      'patientName':     patientName,
      'patientImageUrl': patientImageUrl,
      'doctorId':        doctorId,
      'doctorName':      doctorName,
      'doctorImageUrl':  doctorImageUrl,
      'gigId':    gigId,
      'gigTitle': gigTitle,
      'packageType':         packageType,
      'packageName':         packageName,
      'packagePrice':        packagePrice,
      'packageDeliveryTime': packageDeliveryTime,
      'packageFeatures':     packageFeatures,
      'requirements': requirements.trim(),
      'status':        orderStatusToString(OrderStatus.pendingPayment),
      'paymentStatus': paymentStatusToString(OrderPaymentStatus.pending),
      'paymentMethod':  null,
      'transactionRef': null,
      'videoCallChannelId': ref.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deliveredAt': null,
      'completedAt': null,
    };

    await ref.set(data);

    return OrderModel(
      orderId: ref.id,
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
      requirements: requirements.trim(),
      videoCallChannelId: ref.id,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAYMENT
  // ══════════════════════════════════════════════════════════════════════════

  /// ⚠️ PLACEHOLDER — stands in for the real Stripe round-trip.
  /// Marks the order paid and active immediately. Swap the call site
  /// (BookingProvider.confirmPayment) for a real gateway call later;
  /// this method's signature (paymentMethod + transactionRef) already
  /// matches what a real gateway confirmation would give you.
  Future<void> markPaid({
    required String orderId,
    required String paymentMethod,
    required String transactionRef,
  }) async {
    await _orders.doc(orderId).update({
      'status':        orderStatusToString(OrderStatus.active),
      'paymentStatus': paymentStatusToString(OrderPaymentStatus.paid),
      'paymentMethod':  paymentMethod,
      'transactionRef': transactionRef,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS UPDATES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> markDelivered(String orderId) async {
    await _orders.doc(orderId).update({
      'status': orderStatusToString(OrderStatus.delivered),
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markCompleted(String orderId) async {
    await _orders.doc(orderId).update({
      'status': orderStatusToString(OrderStatus.completed),
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _orders.doc(orderId).update({
      'status': orderStatusToString(OrderStatus.cancelled),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Real-time stream of a patient's orders/appointments, newest first.
  /// Filters on `participantIds` (matches the security rule's own check —
  /// same reasoning as the DM conversations list; see notes there).
  Stream<List<OrderModel>> patientOrdersStream(String patientId) =>
      _orders
          .where('participantIds', arrayContains: patientId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(OrderModel.fromFirestore).toList());

  /// Single order, live — used by the "waiting room" / video call screen
  /// to know the moment the other side is ready, or status changes.
  Stream<OrderModel?> orderStream(String orderId) =>
      _orders.doc(orderId).snapshots().map(
          (d) => d.exists ? OrderModel.fromFirestore(d) : null);

  Future<OrderModel?> getOrder(String orderId) async {
    final d = await _orders.doc(orderId).get();
    if (!d.exists) return null;
    return OrderModel.fromFirestore(d);
  }
}