// lib/models/dm_model.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Firestore schema:
//   Collection: 'conversations'
//     doc: {conversationId}   ← deterministic id = "${patientId}_${doctorId}"
//       fields: participantIds[], patientId, doctorId,
//               patientName, patientImageUrl,
//               doctorName, doctorImageUrl,
//               lastMessage, lastMessageAt, lastSenderId,
//               unreadByPatient, unreadByDoctor, createdAt
//
//   Sub-collection: 'conversations/{id}/messages'
//     doc: {messageId}
//       fields: senderId, senderName, text, type ('text' | 'image'),
//               imageUrl, sentAt, isRead
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGE TYPE
// ══════════════════════════════════════════════════════════════════════════════

enum DmMessageType { text, image }

DmMessageType _typeFromString(String? v) {
  switch (v) {
    case 'image':
      return DmMessageType.image;
    case 'text':
    default:
      return DmMessageType.text;
  }
}

String dmMessageTypeToString(DmMessageType t) =>
    t == DmMessageType.image ? 'image' : 'text';

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGE MODEL
// ══════════════════════════════════════════════════════════════════════════════

class DmMessage {
  final String        messageId;
  final String        senderId;
  final String        senderName;
  final String        text;
  final DmMessageType type;
  final String?       imageUrl;
  final DateTime      sentAt;
  final bool          isRead;

  const DmMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = DmMessageType.text,
    this.imageUrl,
    required this.sentAt,
    this.isRead = false,
  });

  bool get isImage => type == DmMessageType.image;

  factory DmMessage.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DmMessage(
      messageId:  doc.id,
      senderId:   d['senderId']   as String? ?? '',
      senderName: d['senderName'] as String? ?? '',
      text:       d['text']       as String? ?? '',
      type:       _typeFromString(d['type'] as String?),
      imageUrl:   d['imageUrl']   as String?,
      sentAt:     _ts(d['sentAt']),
      isRead:     d['isRead']     as bool?   ?? false,
    );
  }

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    return DateTime.now();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONVERSATION MODEL
// ══════════════════════════════════════════════════════════════════════════════

class DmConversation {
  final String    conversationId;
  final String    patientId;
  final String    doctorId;
  final String    patientName;
  final String    patientImageUrl;
  final String    doctorName;
  final String    doctorImageUrl;
  final String    lastMessage;
  final DateTime? lastMessageAt;
  final String    lastSenderId;
  final int       unreadByPatient;
  final int       unreadByDoctor;
  final DateTime? createdAt;

  const DmConversation({
    required this.conversationId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.patientImageUrl,
    required this.doctorName,
    required this.doctorImageUrl,
    this.lastMessage       = '',
    this.lastMessageAt,
    this.lastSenderId      = '',
    this.unreadByPatient   = 0,
    this.unreadByDoctor    = 0,
    this.createdAt,
  });

  factory DmConversation.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DmConversation(
      conversationId:  doc.id,
      patientId:       d['patientId']       as String? ?? '',
      doctorId:        d['doctorId']        as String? ?? '',
      patientName:     d['patientName']     as String? ?? '',
      patientImageUrl: d['patientImageUrl'] as String? ?? '',
      doctorName:      d['doctorName']      as String? ?? '',
      doctorImageUrl:  d['doctorImageUrl']  as String? ?? '',
      lastMessage:     d['lastMessage']     as String? ?? '',
      lastMessageAt:   _ts(d['lastMessageAt']),
      lastSenderId:    d['lastSenderId']    as String? ?? '',
      unreadByPatient: (d['unreadByPatient'] as num?)?.toInt() ?? 0,
      unreadByDoctor:  (d['unreadByDoctor']  as num?)?.toInt() ?? 0,
      createdAt:       _ts(d['createdAt']),
    );
  }

  static DateTime? _ts(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime)  return v;
    return null;
  }
}