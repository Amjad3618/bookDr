// lib/services/homegig_services.dart  ·  PATIENT APP
//
// Queries the 'gigs' collection — no status filter.
// Every document in the collection is live.
// Collections used: 'gigs', 'patients', 'doctors'
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/dr_model.dart';

class PatientGigService {
  PatientGigService._();
  static final PatientGigService instance = PatientGigService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Collection references ─────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _gigs => _db.collection('gigs');
  CollectionReference<Map<String, dynamic>> get _patients =>
      _db.collection('patients');

  // ══════════════════════════════════════════════════════════════════════════
  // PATIENT PROFILE
  // Fetches from 'patients' collection using Firebase Auth UID
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch current logged-in patient's profile from 'patients' collection
  Future<PatientModel?> fetchCurrentPatient() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;
      final doc = await _patients.doc(uid).get();
      if (!doc.exists) return null;
      return PatientModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchCurrentPatient');
    }
  }

  /// Real-time stream of current patient's profile
  Stream<PatientModel?> streamCurrentPatient() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _patients.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PatientModel.fromFirestore(doc);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH ALL GIGS  — no status filter, every doc is live
  // Ordered: featured first, then by rating, then newest
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<GigModel>> fetchAllGigs() async {
    try {
      // Featured gigs first
      final featuredSnap = await _gigs
          .where('isFeatured', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      // Non-featured gigs by rating
      final regularSnap = await _gigs
          .where('isFeatured', isEqualTo: false)
          .orderBy('rating', descending: true)
          .get();

      final featured = featuredSnap.docs.map(GigModel.fromFirestore).toList();
      final regular = regularSnap.docs.map(GigModel.fromFirestore).toList();

      return [...featured, ...regular];
    } on FirebaseException catch (e) {
      // Fallback: simple fetch ordered by createdAt if index not ready
      if (e.code == 'failed-precondition') {
        return _fetchAllSimple();
      }
      throw _handle(e, 'fetchAllGigs');
    }
  }

  Future<List<GigModel>> _fetchAllSimple() async {
    final snap = await _gigs.orderBy('createdAt', descending: true).get();
    return snap.docs.map(GigModel.fromFirestore).toList();
  }

  // ── Real-time stream of all gigs ──────────────────────────────────────────
  Stream<List<GigModel>> streamAllGigs() {
    return _gigs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GigModel.fromFirestore).toList());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILTER BY CATEGORY
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<GigModel>> fetchByCategory(String category) async {
    try {
      final snap = await _gigs
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .get();
      return snap.docs.map(GigModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchByCategory');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH UNIQUE CATEGORIES from all gigs
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> fetchCategories() async {
    try {
      final snap = await _gigs.get();
      final cats =
          snap.docs
              .map((d) => d.data()['category'] as String? ?? '')
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      return ['All', ...cats];
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchCategories');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH GIGS BY DOCTOR UID
  // Used on doctor profile page in patient app
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<GigModel>> fetchGigsByDoctor(String drId) async {
    try {
      final snap = await _gigs
          .where('drId', isEqualTo: drId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(GigModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchGigsByDoctor');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH SINGLE GIG BY ID
  // ══════════════════════════════════════════════════════════════════════════

  Future<GigModel?> fetchById(String gigId) async {
    try {
      final doc = await _gigs.doc(gigId).get();
      if (!doc.exists) return null;
      return GigModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchById');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INCREMENT VIEW COUNTER
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> incrementViews(String gigId) async {
    try {
      await _gigs.doc(gigId).update({'totalViews': FieldValue.increment(1)});
    } catch (_) {}
  }

  // ── Error handler ─────────────────────────────────────────────────────────
  Exception _handle(FirebaseException e, String op) {
    final msg = switch (e.code) {
      'permission-denied' => 'Access denied. Check Firestore rules.',
      'unavailable' => 'Network unavailable. Please try again.',
      'not-found' => 'Document not found.',
      'deadline-exceeded' => 'Request timed out.',
      'failed-precondition' =>
        'Missing Firestore index. Open Firebase Console → Firestore → Indexes to create it.',
      _ => 'Error in $op [${e.code}]: ${e.message}',
    };
    return Exception(msg);
  }
}
