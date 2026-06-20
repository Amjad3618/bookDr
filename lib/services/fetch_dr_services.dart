// lib/services/doctor_services.dart  ·  PATIENT APP
//
// Queries the 'doctors' collection.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fetch_de_model.dart';


class DoctorService {
  DoctorService._();
  static final DoctorService instance = DoctorService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection reference ──────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _doctors =>
      _db.collection('doctors');

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH ALL DOCTORS — ordered by rating, falls back if index isn't ready
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<fetchDoctorModel>> fetchAllDoctors() async {
    try {
      final snap = await _doctors
          .orderBy('rating', descending: true)
          .get();
      return snap.docs.map(fetchDoctorModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        return _fetchAllSimple();
      }
      throw _handle(e, 'fetchAllDoctors');
    }
  }

  Future<List<fetchDoctorModel>> _fetchAllSimple() async {
    final snap = await _doctors.get();
    return snap.docs.map(fetchDoctorModel.fromFirestore).toList();
  }

  // ── Real-time stream of all doctors ───────────────────────────────────────
  Stream<List<fetchDoctorModel>> streamAllDoctors() {
    return _doctors
        .snapshots()
        .map((s) => s.docs.map(fetchDoctorModel.fromFirestore).toList());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILTER BY SPECIALTY
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<fetchDoctorModel>> fetchBySpecialty(String specialty) async {
    try {
      final snap = await _doctors
          .where('specialty', isEqualTo: specialty)
          .get();
      return snap.docs.map(fetchDoctorModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchBySpecialty');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH UNIQUE SPECIALTIES
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> fetchSpecialties() async {
    try {
      final snap = await _doctors.get();
      final specs = snap.docs
          .map((d) => d.data()['specialty'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return ['All', ...specs];
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchSpecialties');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH SINGLE DOCTOR BY UID
  // ══════════════════════════════════════════════════════════════════════════

  Future<fetchDoctorModel?> fetchById(String drId) async {
    try {
      final doc = await _doctors.doc(drId).get();
      if (!doc.exists) return null;
      return fetchDoctorModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchById');
    }
  }

  // ── Error handler ─────────────────────────────────────────────────────────
  Exception _handle(FirebaseException e, String op) {
    final msg = switch (e.code) {
      'permission-denied'   => 'Access denied. Check Firestore rules.',
      'unavailable'         => 'Network unavailable. Please try again.',
      'not-found'           => 'Document not found.',
      'deadline-exceeded'   => 'Request timed out.',
      'failed-precondition' =>
          'Missing Firestore index. Open Firebase Console → Firestore → Indexes to create it.',
      _ => 'Error in $op [${e.code}]: ${e.message}',
    };
    return Exception(msg);
  }
}