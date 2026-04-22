// lib/services/patient_auth_service.dart
// CareSync Patients (bookdr)

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/patient_model.dart';

class PatientAuthService {
  final _auth    = FirebaseAuth.instance;
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  CollectionReference get _patients => _db.collection('patients');

  // ── Auth state stream ──────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentUser      => _auth.currentUser;

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER
  // ══════════════════════════════════════════════════════════════════════════

  Future<PatientAuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    File?           profileImage,
    void Function(double progress)? onImageProgress,
  }) async {
    UserCredential? cred;
    try {
      // 1. Firebase Auth
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password.trim());
      final uid = cred.user!.uid;

      // 2. Upload profile image
      String? photoUrl;
      if (profileImage != null) {
        photoUrl = await _uploadProfileImage(
          uid: uid, file: profileImage, onProgress: onImageProgress);
      }

      // 3. Update display name
      try { await cred.user!.updateDisplayName(name.trim()); } catch (_) {}

      // 4. Save to Firestore
      final patient = PatientModel(
        patientId:      uid,
        name:           name.trim(),
        email:          email.trim(),
        phone:          phone.trim(),
        profileImageUrl:photoUrl,
        walletBalance:  0,
        totalSpent:     0,
        isActive:       true,
        isVerified:     false,
        createdAt:      DateTime.now(),
      );

      await _patients.doc(uid).set({
        ...patient.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return PatientAuthResult.success(patient);

    } on FirebaseAuthException catch (e) {
      return PatientAuthResult.error(_authError(e.code));
    } on FirebaseException catch (e) {
      // Firestore write failed — roll back Auth user
      if (cred != null) { try { await cred.user!.delete(); } catch (_) {} }
      return PatientAuthResult.error(
        'Profile save failed [${e.code}]: Check Firestore rules.');
    } catch (e) {
      if (cred != null) { try { await cred.user!.delete(); } catch (_) {} }
      return PatientAuthResult.error('Registration failed: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════════════════════

  Future<PatientAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
      final uid = cred.user!.uid;

      // Retry up to 3 times (edge case: Firestore write still in-flight)
      PatientModel? patient;
      for (int i = 0; i < 3; i++) {
        patient = await getPatientById(uid);
        if (patient != null) break;
        await Future.delayed(Duration(milliseconds: 400 * (i + 1)));
      }

      if (patient == null) {
        return PatientAuthResult.error(
          'Profile not found. Check Firestore Security Rules.\n'
          'UID: $uid');
      }
      return PatientAuthResult.success(patient);

    } on FirebaseAuthException catch (e) {
      return PatientAuthResult.error(_authError(e.code));
    } on FirebaseException catch (e) {
      return PatientAuthResult.error(
        'Login failed [${e.code}]: ${e.message}');
    } catch (e) {
      return PatientAuthResult.error('Login failed: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> logout() async {
    try { await _auth.signOut(); } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ══════════════════════════════════════════════════════════════════════════

  Future<PatientAuthResult> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return PatientAuthResult.message(
        'Password reset link sent to ${email.trim()}');
    } on FirebaseAuthException catch (e) {
      return PatientAuthResult.error(_authError(e.code));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET PATIENT BY UID — safe, never throws
  // ══════════════════════════════════════════════════════════════════════════

  Future<PatientModel?> getPatientById(String uid) async {
    try {
      final snap = await _patients.doc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return PatientModel.fromJson(snap.data() as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REAL-TIME PATIENT STREAM
  // ══════════════════════════════════════════════════════════════════════════

  Stream<PatientModel?> patientStream(String uid) =>
    _patients.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      try { return PatientModel.fromJson(snap.data() as Map<String, dynamic>); }
      catch (_) { return null; }
    });

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> updatePatient(String uid, Map<String, dynamic> fields) async {
    try {
      await _patients.doc(uid).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD PROFILE IMAGE
  // ══════════════════════════════════════════════════════════════════════════

  Future<String?> _uploadProfileImage({
    required String uid,
    required File   file,
    void Function(double)? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final ref   = _storage
          .ref().child('patient_images').child(uid).child('profile.jpg');

      final task = ref.putData(bytes,
          SettableMetadata(contentType: 'image/jpeg'));

      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress?.call(snap.bytesTransferred / snap.totalBytes);
        }
      });

      await task;
      return await ref.getDownloadURL();
    } catch (_) { return null; }
  }

  Future<String?> uploadAndSaveProfileImage({
    required String uid, required File file,
    void Function(double)? onProgress,
  }) async {
    final url = await _uploadProfileImage(
        uid: uid, file: file, onProgress: onProgress);
    if (url != null) {
      await updatePatient(uid, {'profileImageUrl': url});
    }
    return url;
  }

  // ── Error mapper ───────────────────────────────────────────────────────────
  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email. Please register.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Please login.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'user-disabled':
        return 'Your account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AUTH RESULT
// ══════════════════════════════════════════════════════════════════════════════

class PatientAuthResult {
  final PatientModel? patient;
  final String?       errorMessage;
  final String?       successMessage;
  final bool          isSuccess;

  PatientAuthResult._({
    this.patient, this.errorMessage, this.successMessage,
    required this.isSuccess,
  });

  factory PatientAuthResult.success(PatientModel p) =>
      PatientAuthResult._(patient: p, isSuccess: true);

  factory PatientAuthResult.error(String msg) =>
      PatientAuthResult._(errorMessage: msg, isSuccess: false);

  factory PatientAuthResult.message(String msg) =>
      PatientAuthResult._(successMessage: msg, isSuccess: true);
}