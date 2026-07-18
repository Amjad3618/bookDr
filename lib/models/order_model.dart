// lib/models/order_model.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// The "order" is CareSync's equivalent of a Fiverr order / an appointment.
// One Firestore doc per booking. Both patient app and doctor app read from
// the SAME 'orders' collection — this model's shape should be mirrored
// exactly on the doctor app side (same field names) so both apps agree.
//
// Firestore schema:
//   Collection: 'orders'
//     doc: {orderId}
//       participantIds: [patientId, doctorId]   ← for security rules & queries
//       patientId, patientName, patientImageUrl
//       doctorId, doctorName, doctorImageUrl
//       gigId, gigTitle
//       packageType: 'basic' | 'standard' | 'premium'
//       packageName, packagePrice, packageDeliveryTime, packageFeatures[]
//       requirements: patient's answer to the gig's requirements question
//       status: 'pendingPayment' | 'active' | 'delivered' | 'completed' | 'cancelled'
//       paymentStatus: 'pending' | 'paid' | 'refunded'
//       paymentMethod: 'jazzcash' | ... (null until paid)
//       transactionRef: gateway's reference once paid
//       videoCallChannelId: unique room id for ZegoCloud, = orderId
//       createdAt, updatedAt, deliveredAt, completedAt
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