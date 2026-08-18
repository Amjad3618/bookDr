// lib/services/order_services.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Handles Firestore reads/writes for the 'orders' collection.
//
// ⚠️ SYNC NOTE: CareSyncDr (doctor app) reads a SEPARATE 'appointments'
// collection (see AppointmentService.doctorAppointmentsStream, filtered on
// 'drId' + orderBy('createdAt')). Orders created here were never mirrored
// there, so doctor-side never saw new bookings. Fix: every time we create
// or cancel an order here, we also write/update a matching document in
// 'appointments' — same doc id as the order (ref.id), so the two stay
// linked 1:1. Field names below match AppointmentModel.fromJson exactly
// (drId, patientId, gigTitle, packageName, price, consultMode, status...).
// If AppointmentModel's fields ever change on the doctor side, update the
// `appointmentData` map below to match.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection('orders');
  CollectionReference get _appointments => _db.collection('appointments');

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE ORDER  (+ mirrored 'appointments' doc so CareSyncDr sees it)
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
                                // and reused as the appointmentId so the two
                                // docs stay 1:1 linked.

    final orderData = {
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
      'deliveryDeadline': null, // set once payment succeeds — see markPaid()
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deliveredAt': null,
      'completedAt': null,
    };

    // Mirrored doc for CareSyncDr — field names match AppointmentModel.fromJson.
    final appointmentData = {
      'appointmentId':      ref.id,
      'drId':               doctorId,
      'drName':             doctorName,
      'drImageUrl':         doctorImageUrl,
      'patientId':          patientId,
      'patientName':        patientName,
      'patientImageUrl':    patientImageUrl,
      'patientAge':         '',
      'gigId':              gigId,
      'gigTitle':           gigTitle,
      'packageName':        packageName,
      'price':              packagePrice,
      'consultMode':        'videoCall', // matches ConsultMode.videoCall.name
      'status':             'pending',   // matches AppointmentStatus.pending.name
      'scheduledAt':        null,
      'completedAt':        null,
      'cancelledAt':        null,
      'cancellationReason': null,
      'refunded':           false,
      'patientNote':        requirements.trim(),
      'durationMinutes':    30,
      'rating':             0,
      'review':             null,
      'prescriptionIssued': false,
      'createdAt':          FieldValue.serverTimestamp(),
      'updatedAt':          FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(ref, orderData);
    batch.set(_appointments.doc(ref.id), appointmentData);
    await batch.commit();

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

  /// ⚠️ PLACEHOLDER payment confirmation — see BookingProvider for the real
  /// Stripe flow this will be swapped for. Regardless of the payment
  /// method, this is also where the DELIVERY COUNTDOWN starts: the moment
  /// payment is confirmed, we compute `deliveryDeadline` = now + the
  /// package's delivery time, and store it. Both apps read this same
  /// stored timestamp, so their countdowns always agree.
  ///
  /// Note: we don't touch the mirrored 'appointments' doc here — it stays
  /// 'pending' until the doctor accepts/declines it in CareSyncDr, which
  /// is exactly the existing doctor-side workflow.
  Future<void> markPaid({
    required String orderId,
    required String paymentMethod,
    required String transactionRef,
    required String packageDeliveryTime,
  }) async {
    final deadline =
        DateTime.now().add(parseDeliveryDuration(packageDeliveryTime));

    await _orders.doc(orderId).update({
      'status':        orderStatusToString(OrderStatus.active),
      'paymentStatus': paymentStatusToString(OrderPaymentStatus.paid),
      'paymentMethod':  paymentMethod,
      'transactionRef': transactionRef,
      'deliveryDeadline': Timestamp.fromDate(deadline),
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

  /// Patient-side cancel — also cancels the mirrored appointment doc so it
  /// moves out of CareSyncDr's Pending/Upcoming tabs into Cancelled.
  Future<void> cancelOrder(String orderId) async {
    final batch = _db.batch();

    batch.update(_orders.doc(orderId), {
      'status': orderStatusToString(OrderStatus.cancelled),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final apptRef = _appointments.doc(orderId);
    final apptSnap = await apptRef.get();
    if (apptSnap.exists) {
      batch.update(apptRef, {
        'status':             'cancelled',
        'cancellationReason': 'Cancelled by patient',
        'cancelledAt':        FieldValue.serverTimestamp(),
        'refunded':           false,
        'updatedAt':          FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  Stream<List<OrderModel>> patientOrdersStream(String patientId) =>
      _orders
          .where('participantIds', arrayContains: patientId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(OrderModel.fromFirestore).toList());

  /// Doctor-side equivalent — same query shape, different id. Use this
  /// exact method (or its mirror) on the doctor app's OrderService too.
  Stream<List<OrderModel>> doctorOrdersStream(String doctorId) =>
      _orders
          .where('participantIds', arrayContains: doctorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(OrderModel.fromFirestore).toList());

  Stream<OrderModel?> orderStream(String orderId) =>
      _orders.doc(orderId).snapshots().map(
          (d) => d.exists ? OrderModel.fromFirestore(d) : null);

  Future<OrderModel?> getOrder(String orderId) async {
    final d = await _orders.doc(orderId).get();
    if (!d.exists) return null;
    return OrderModel.fromFirestore(d);
  }
}