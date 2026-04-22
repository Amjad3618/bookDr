// lib/providers/patient_auth_provider.dart
// CareSync Patients (bookdr)

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../services/auth_services.dart';

enum PatientAuthState { initial, loading, authenticated, unauthenticated, error }

class PatientAuthProvider extends ChangeNotifier {
  final PatientAuthService _service = PatientAuthService();

  // ── State ──────────────────────────────────────────────────────────────────
  PatientAuthState _state        = PatientAuthState.initial;
  PatientModel?    _patient      = null;
  String?          _errorMessage = null;
  bool             _isLoading    = false;

  // Upload progress for profile image
  double  _uploadProgress = 0.0;
  bool    _isUploading    = false;

  // Guard flag — prevents authStateChanges from fighting login/register
  bool _handlingManually = false;

  StreamSubscription? _authSub;
  StreamSubscription? _patientSub;

  // ── Getters ────────────────────────────────────────────────────────────────
  PatientAuthState get state           => _state;
  PatientModel?    get patient         => _patient;
  String?          get errorMessage    => _errorMessage;
  bool             get isLoading       => _isLoading;
  bool             get isAuthenticated => _state == PatientAuthState.authenticated;
  double           get uploadProgress  => _uploadProgress;
  bool             get isUploading     => _isUploading;

  double get walletBalance => _patient?.walletBalance ?? 0;
  double get totalSpent    => _patient?.totalSpent    ?? 0;

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALIZE — restores session on cold app start
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    _setState(PatientAuthState.loading);

    _authSub = _service.authStateChanges.listen((user) async {
      if (_handlingManually) return;

      if (user != null) {
        PatientModel? p;
        for (int i = 0; i < 3; i++) {
          p = await _service.getPatientById(user.uid);
          if (p != null) break;
          await Future.delayed(const Duration(milliseconds: 600));
        }

        if (p != null) {
          _patient = p;
          _setState(PatientAuthState.authenticated);
          _startPatientStream(user.uid);
        } else {
          // Auth exists but no Firestore doc — sign out cleanly
          await _service.logout();
          _setState(PatientAuthState.unauthenticated);
        }
      } else {
        _patient = null;
        _patientSub?.cancel();
        _setState(PatientAuthState.unauthenticated);
      }
    });
  }

  void _startPatientStream(String uid) {
    _patientSub?.cancel();
    _patientSub = _service.patientStream(uid).listen((p) {
      if (p != null) { _patient = p; notifyListeners(); }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    _handlingManually = true;

    try {
      final result = await _service.login(email: email, password: password);

      if (result.isSuccess && result.patient != null) {
        _patient = result.patient;
        _setState(PatientAuthState.authenticated);
        _startPatientStream(_patient!.patientId);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _setState(PatientAuthState.unauthenticated);
        _setLoading(false);
        return false;
      }
    } finally {
      _handlingManually = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    File?           profileImage,
  }) async {
    _setLoading(true);
    _clearError();
    _handlingManually = true;

    try {
      final result = await _service.register(
        name:         name,
        email:        email,
        phone:        phone,
        password:     password,
        profileImage: profileImage,
        onImageProgress: (p) {
          _uploadProgress = p;
          _isUploading    = p < 1.0;
          notifyListeners();
        },
      );

      if (result.isSuccess && result.patient != null) {
        _patient = result.patient;
        _setState(PatientAuthState.authenticated);
        _startPatientStream(_patient!.patientId);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.errorMessage;
        _setState(PatientAuthState.unauthenticated);
        _setLoading(false);
        return false;
      }
    } finally {
      _handlingManually = false;
      _isUploading      = false;
      _uploadProgress   = 0;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> logout() async {
    _handlingManually = true;
    _patientSub?.cancel();
    await _service.logout();
    _patient = null;
    _setState(PatientAuthState.unauthenticated);
    _handlingManually = false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    final result = await _service.forgotPassword(email);
    _setLoading(false);
    return result.isSuccess ? null : result.errorMessage;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    if (_patient == null) return;
    try {
      await _service.updatePatient(_patient!.patientId, fields);
      _patient = _patient!.copyWith(
        name:           fields['name'],
        phone:          fields['phone'],
        dateOfBirth:    fields['dateOfBirth'],
        gender:         fields['gender'],
        bloodGroup:     fields['bloodGroup'],
        address:        fields['address'],
        city:           fields['city'],
        profileImageUrl:fields['profileImageUrl'],
      );
      notifyListeners();
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD + SAVE PROFILE IMAGE
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> uploadProfileImage(File imageFile) async {
    if (_patient == null) return null;
    _isUploading    = true;
    _uploadProgress = 0;
    notifyListeners();

    final url = await _service.uploadAndSaveProfileImage(
      uid:  _patient!.patientId,
      file: imageFile,
      onProgress: (p) {
        _uploadProgress = p;
        notifyListeners();
      },
    );

    if (url != null) {
      _patient = _patient!.copyWith(profileImageUrl: url);
    }
    _isUploading = false;
    notifyListeners();
    return url;
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  void _setState(PatientAuthState s) { _state = s; notifyListeners(); }
  void _setLoading(bool v)           { _isLoading = v; notifyListeners(); }
  void _clearError()                 { _errorMessage = null; }

  @override
  void dispose() {
    _authSub?.cancel();
    _patientSub?.cancel();
    super.dispose();
  }
}