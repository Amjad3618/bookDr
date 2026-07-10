// lib/providers/dm_list_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Powers the "Chats" list screen — shows every doctor conversation the
// currently logged-in patient has, newest first, with unread counts.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/dm_model.dart';
import '../services/dm_services.dart';

class DmListProvider extends ChangeNotifier {
  final DmService _service = DmService();

  List<DmConversation> _conversations = [];
  bool                  _isLoading    = true;
  String?               _errorMessage;

  StreamSubscription<List<DmConversation>>? _sub;

  List<DmConversation> get conversations => _conversations;
  bool                 get isLoading     => _isLoading;
  String?              get errorMessage  => _errorMessage;
  bool                 get isEmpty       =>
      !_isLoading && _errorMessage == null && _conversations.isEmpty;

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALISE
  // ══════════════════════════════════════════════════════════════════════════

  void initialise(String patientId) {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.conversationsStream(patientId).listen(
      (list) {
        _conversations = list;
        _isLoading     = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading    = false;
        _errorMessage = 'Could not load your chats. Please try again.';
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