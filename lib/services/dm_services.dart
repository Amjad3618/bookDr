// lib/services/dm_service.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Handles all Firestore reads/writes + Storage uploads for the DM feature.
//
// Conversation doc ID is deterministic:
//   "${patientId}_${doctorId}"
// This means we never create duplicates — opening a chat with the
// same doctor always lands in the same conversation, and it also lets
// the Firestore/Storage security rules verify membership just by
// splitting the id (see firestore.rules / storage.rules provided
// alongside this file).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/dm_model.dart';

class DmService {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ── Collection helpers ─────────────────────────────────────────────────────
  CollectionReference get _conversations => _db.collection('conversations');

  DocumentReference _convDoc(String convId) => _conversations.doc(convId);

  CollectionReference _messages(String convId) =>
      _conversations.doc(convId).collection('messages');

  // ── Deterministic conversation ID ─────────────────────────────────────────
  String convId(String patientId, String doctorId) =>
      '${patientId}_$doctorId';

  // ══════════════════════════════════════════════════════════════════════════
  // GET OR CREATE CONVERSATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns the existing conversation or creates a new one.
  /// Call this when the patient taps the DM/Chat button on a gig card.
  Future<DmConversation> getOrCreateConversation({
    required String patientId,
    required String patientName,
    required String patientImageUrl,
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
  }) async {
    final id  = convId(patientId, doctorId);
    final ref = _convDoc(id);
    final snap = await ref.get();

    if (snap.exists) {
      return DmConversation.fromFirestore(snap);
    }

    // Create fresh conversation
    final data = {
      'conversationId':  id,
      'patientId':       patientId,
      'doctorId':        doctorId,
      'patientName':     patientName,
      'patientImageUrl': patientImageUrl,
      'doctorName':      doctorName,
      'doctorImageUrl':  doctorImageUrl,
      // participantIds is what the security rules check against —
      // ALWAYS keep exactly [patientId, doctorId] here.
      'participantIds':  [patientId, doctorId],
      'lastMessage':     '',
      'lastMessageAt':   null,
      'lastSenderId':    '',
      'unreadByPatient': 0,
      'unreadByDoctor':  0,
      'createdAt':       FieldValue.serverTimestamp(),
    };

    await ref.set(data);

    // Return a local copy (serverTimestamp won't resolve immediately)
    return DmConversation(
      conversationId:  id,
      patientId:       patientId,
      doctorId:        doctorId,
      patientName:     patientName,
      patientImageUrl: patientImageUrl,
      doctorName:      doctorName,
      doctorImageUrl:  doctorImageUrl,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE  (text and/or image)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String          text = '',
    String?         imageUrl,
    DmMessageType   type = DmMessageType.text,
    required bool   senderIsPatient,
  }) async {
    final batch = _db.batch();

    // 1. Add message document
    final msgRef = _messages(conversationId).doc();
    batch.set(msgRef, {
      'senderId':   senderId,
      'senderName': senderName,
      'text':       text.trim(),
      'type':       dmMessageTypeToString(type),
      'imageUrl':   imageUrl,
      'sentAt':     FieldValue.serverTimestamp(),
      'isRead':     false,
    });

    // 2. Update conversation metadata (preview text differs for images)
    final preview = type == DmMessageType.image ? '📷 Photo' : text.trim();

    batch.update(_convDoc(conversationId), {
      'lastMessage':    preview,
      'lastMessageAt':  FieldValue.serverTimestamp(),
      'lastSenderId':   senderId,
      // Increment unread counter for the OTHER side
      if (senderIsPatient)
        'unreadByDoctor':  FieldValue.increment(1)
      else
        'unreadByPatient': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD CHAT IMAGE
  // ══════════════════════════════════════════════════════════════════════════

  /// Uploads a picked image to
  ///   chat_images/{conversationId}/{timestamp}_{senderId}.jpg
  /// and returns the download URL. Path is scoped under the conversationId
  /// so the Storage rules can restrict access to just the two participants.
  Future<String> uploadChatImage({
    required String conversationId,
    required String senderId,
    required File   file,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$senderId.jpg';
    final ref = _storage
        .ref()
        .child('chat_images')
        .child(conversationId)
        .child(fileName);

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Real-time stream of messages in a conversation, oldest first.
  Stream<List<DmMessage>> messagesStream(String conversationId) =>
      _messages(conversationId)
          .orderBy('sentAt', descending: false)
          .snapshots()
          .map((s) => s.docs.map(DmMessage.fromFirestore).toList());

  /// Real-time stream of all conversations for a patient, newest first.
  ///
  /// IMPORTANT: this filters on `participantIds` (array-contains) rather
  /// than `patientId` (==). Firestore security rules for `list` queries
  /// must be statically verifiable from the query itself — since our rule
  /// checks `request.auth.uid in resource.data.participantIds`, the query
  /// has to filter on that *same* field, or Firestore denies the whole
  /// request with PERMISSION_DENIED (it can't retroactively confirm that
  /// `patientId == uid` implies `uid` is in `participantIds`, even though
  /// that's always true by construction).
  Stream<List<DmConversation>> conversationsStream(String patientId) =>
      _conversations
          .where('participantIds', arrayContains: patientId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map(DmConversation.fromFirestore).toList());

  // ══════════════════════════════════════════════════════════════════════════
  // MARK AS READ
  // ══════════════════════════════════════════════════════════════════════════

  /// Call when patient opens a conversation to reset their unread counter.
  Future<void> markReadByPatient(String conversationId) async {
    await _convDoc(conversationId).update({'unreadByPatient': 0});
  }
}