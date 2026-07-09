// lib/providers/dm_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dm_model.dart';
import '../services/dm_services.dart';

class DmProvider extends ChangeNotifier {
  final DmService _service = DmService();

  // ── Conversation context ───────────────────────────────────────────────────
  // Nullable — safe to access before initialise() completes
  DmConversation? _conversation;
  String          _currentPatientId   = '';
  String          _currentPatientName = '';

  // ── State ──────────────────────────────────────────────────────────────────
  List<DmMessage> _messages          = [];
  bool            _isLoading         = true;
  bool            _isSending         = false;
  bool            _isUploadingImage  = false;
  String?         _errorMessage;

  StreamSubscription<List<DmMessage>>? _msgSub;

  // ── Getters ────────────────────────────────────────────────────────────────
  DmConversation? get conversation      => _conversation;
  List<DmMessage> get messages          => _messages;
  bool            get isLoading         => _isLoading;
  bool            get isSending         => _isSending;
  bool            get isUploadingImage  => _isUploadingImage;
  String?         get errorMessage      => _errorMessage;

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALISE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialise({
    required String patientId,
    required String patientName,
    required String patientImageUrl,
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
  }) async {
    _currentPatientId   = patientId;
    _currentPatientName = patientName;
    _isLoading          = true;
    _errorMessage       = null;
    notifyListeners();

    try {
      _conversation = await _service.getOrCreateConversation(
        patientId:       patientId,
        patientName:     patientName,
        patientImageUrl: patientImageUrl,
        doctorId:        doctorId,
        doctorName:      doctorName,
        doctorImageUrl:  doctorImageUrl,
      );

      await _service.markReadByPatient(_conversation!.conversationId);

      _msgSub = _service
          .messagesStream(_conversation!.conversationId)
          .listen(
        (msgs) {
          _messages  = msgs;
          _isLoading = false;
          notifyListeners();
        },
        onError: (_) {
          _isLoading    = false;
          _errorMessage = 'Failed to load messages.';
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading    = false;
      _errorMessage = 'Could not open chat. Please try again.';
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND TEXT MESSAGE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending || _conversation == null) return;

    _isSending = true;
    notifyListeners();

    try {
      await _service.sendMessage(
        conversationId:  _conversation!.conversationId,
        senderId:        _currentPatientId,
        senderName:      _currentPatientName,
        text:            text,
        type:            DmMessageType.text,
        senderIsPatient: true,
      );
    } catch (_) {
      _errorMessage = 'Message failed to send.';
      notifyListeners();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND IMAGE MESSAGE
  // ══════════════════════════════════════════════════════════════════════════

  /// Uploads [imageFile] to Storage, then writes an image-type message.
  Future<void> sendImageMessage(File imageFile) async {
    if (_isUploadingImage || _conversation == null) return;

    _isUploadingImage = true;
    _errorMessage     = null;
    notifyListeners();

    try {
      final url = await _service.uploadChatImage(
        conversationId: _conversation!.conversationId,
        senderId:       _currentPatientId,
        file:           imageFile,
      );

      await _service.sendMessage(
        conversationId:  _conversation!.conversationId,
        senderId:        _currentPatientId,
        senderName:      _currentPatientName,
        imageUrl:        url,
        type:            DmMessageType.image,
        senderIsPatient: true,
      );
    } catch (_) {
      _errorMessage = 'Photo failed to send.';
      notifyListeners();
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }
}