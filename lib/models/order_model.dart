// lib/models/order_model.dart  ·  PATIENT APP  (mirror this on doctor app too)
// ════════════════════════════════════════════════════════════════════════════
// SAME schema as before, with ONE addition: `deliveryDeadline`.
//
// This is computed ONCE, server-side-equivalent (inside OrderService.markPaid,
// at the moment payment succeeds), and stored in Firestore. Both apps read
// the SAME stored deadline — that's what keeps the countdown perfectly in
// sync between patient and doctor without either app needing to talk to
// the other directly. Each app just ticks its own local Timer against the
// same fixed deadline.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ══════════════════════════════════════════════════════════════════════════════

enum OrderStatus { pendingPayment, active, delivered, completed, cancelled }

OrderStatus orderStatusFromString(String? v) {
  switch (v) {
    case 'active':      return OrderStatus.active;
    case 'delivered':   return OrderStatus.delivered;
    case 'completed':   return OrderStatus.completed;
    case 'cancelled':   return OrderStatus.cancelled;
    case 'pendingPayment':
    default:            return OrderStatus.pendingPayment;
  }
}

String orderStatusToString(OrderStatus s) => s.name;

enum OrderPaymentStatus { pending, paid, refunded }

OrderPaymentStatus paymentStatusFromString(String? v) {
  switch (v) {
    case 'paid':     return OrderPaymentStatus.paid;
    case 'refunded': return OrderPaymentStatus.refunded;
    case 'pending':
    default:         return OrderPaymentStatus.pending;
  }
}

String paymentStatusToString(OrderPaymentStatus s) => s.name;

// ══════════════════════════════════════════════════════════════════════════════
// DELIVERY-TIME PARSER
// ══════════════════════════════════════════════════════════════════════════════

/// Converts the gig package's delivery-time label (one of the fixed strings
/// used in create_gig_view.dart's `_deliveries` list) into a Duration.
/// Falls back to 24 hours for anything unrecognised.
Duration parseDeliveryDuration(String label) {
  switch (label) {
    case '3 hours':  return const Duration(hours: 3);
    case '6 hours':  return const Duration(hours: 6);
    case '12 hours': return const Duration(hours: 12);
    case '1 day':    return const Duration(days: 1);
    case '2 days':   return const Duration(days: 2);
    case '3 days':   return const Duration(days: 3);
    case '5 days':   return const Duration(days: 5);
    case '7 days':   return const Duration(days: 7);
    default:         return const Duration(hours: 24);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ORDER MODEL
// ══════════════════════════════════════════════════════════════════════════════

class OrderModel {
  final String orderId;

  final String patientId;
  final String patientName;
  final String patientImageUrl;

  final String doctorId;
  final String doctorName;
  final String doctorImageUrl;

  final String gigId;
  final String gigTitle;

  final String       packageType;   // 'basic' | 'standard' | 'premium'
  final String       packageName;
  final double        packagePrice;
  final String        packageDeliveryTime;
  final List<String>  packageFeatures;

  final String requirements;

  final OrderStatus        status;
  final OrderPaymentStatus paymentStatus;
  final String?            paymentMethod;
  final String?            transactionRef;

  final String videoCallChannelId;

  /// When the delivery countdown ends — set once, the moment payment is
  /// confirmed. Null until then (no countdown before the order is active).
  final DateTime? deliveryDeadline;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.orderId,
    required this.patientId,
    required this.patientName,
    required this.patientImageUrl,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.gigId,
    required this.gigTitle,
    required this.packageType,
    required this.packageName,
    required this.packagePrice,
    required this.packageDeliveryTime,
    required this.packageFeatures,
    required this.requirements,
    this.status         = OrderStatus.pendingPayment,
    this.paymentStatus   = OrderPaymentStatus.pending,
    this.paymentMethod,
    this.transactionRef,
    required this.videoCallChannelId,
    this.deliveryDeadline,
    this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.completedAt,
  });

  bool get isPaid      => paymentStatus == OrderPaymentStatus.paid;
  bool get isActive     => status == OrderStatus.active;
  bool get isCompleted  => status == OrderStatus.completed;
  bool get isCancelled  => status == OrderStatus.cancelled;
  bool get canJoinCall  => isPaid && (status == OrderStatus.active || status == OrderStatus.delivered);

  /// Time left until delivery is due, or Duration.zero if already passed
  /// or no deadline set yet.
  Duration get timeRemaining {
    if (deliveryDeadline == null) return Duration.zero;
    final diff = deliveryDeadline!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isOverdue =>
      deliveryDeadline != null && DateTime.now().isAfter(deliveryDeadline!);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      orderId:  doc.id,
      patientId: d['patientId'] as String? ?? '',
      patientName: d['patientName'] as String? ?? '',
      patientImageUrl: d['patientImageUrl'] as String? ?? '',
      doctorId: d['doctorId'] as String? ?? '',
      doctorName: d['doctorName'] as String? ?? '',
      doctorImageUrl: d['doctorImageUrl'] as String? ?? '',
      gigId: d['gigId'] as String? ?? '',
      gigTitle: d['gigTitle'] as String? ?? '',
      packageType: d['packageType'] as String? ?? 'basic',
      packageName: d['packageName'] as String? ?? '',
      packagePrice: (d['packagePrice'] as num?)?.toDouble() ?? 0,
      packageDeliveryTime: d['packageDeliveryTime'] as String? ?? '',
      packageFeatures: (d['packageFeatures'] as List?)?.cast<String>() ?? const [],
      requirements: d['requirements'] as String? ?? '',
      status: orderStatusFromString(d['status'] as String?),
      paymentStatus: paymentStatusFromString(d['paymentStatus'] as String?),
      paymentMethod: d['paymentMethod'] as String?,
      transactionRef: d['transactionRef'] as String?,
      videoCallChannelId: d['videoCallChannelId'] as String? ?? doc.id,
      deliveryDeadline: _ts(d['deliveryDeadline']),
      createdAt:   _ts(d['createdAt']),
      updatedAt:   _ts(d['updatedAt']),
      deliveredAt: _ts(d['deliveredAt']),
      completedAt: _ts(d['completedAt']),
    );
  }

  static DateTime? _ts(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    return null;
  }
}