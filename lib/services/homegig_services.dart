// lib/services/homegig_services.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/dr_model.dart';

class PatientGigService {
  PatientGigService._();
  static final PatientGigService instance = PatientGigService._();

  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _gigs =>
      _db.collection('gigs');
  CollectionReference<Map<String, dynamic>> get _patients =>
      _db.collection('patients');

  // ══════════════════════════════════════════════════════════════════════════
  // PATIENT PROFILE
  // ══════════════════════════════════════════════════════════════════════════

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

  Stream<PatientModel?> streamCurrentPatient() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _patients.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PatientModel.fromFirestore(doc);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH ALL GIGS
  // FIX: Single query instead of two sequential queries.
  // Two queries (featured + non-featured) were blocking the UI thread
  // for ~800ms–2s on every home load and every navigation tap.
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<GigModel>> fetchAllGigs() async {
    try {
      // Single query — sort client-side (avoids composite index requirement
      // and cuts Firestore round-trips from 2 → 1)
      final snap = await _gigs
          .orderBy('rating', descending: true)
          .get();

      final all = snap.docs.map(GigModel.fromFirestore).toList();

      // Put featured gigs first, then rest by rating (already sorted)
      final featured = all.where((g) => g.isFeatured).toList();
      final regular  = all.where((g) => !g.isFeatured).toList();
      return [...featured, ...regular];
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') return _fetchAllSimple();
      throw _handle(e, 'fetchAllGigs');
    }
  }

  Future<List<GigModel>> _fetchAllSimple() async {
    final snap = await _gigs.orderBy('createdAt', descending: true).get();
    return snap.docs.map(GigModel.fromFirestore).toList();
  }

  Stream<List<GigModel>> streamAllGigs() {
    return _gigs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(GigModel.fromFirestore).toList());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // FIX: Build from already-fetched gigs instead of extra Firestore read.
  // Previously fetchCategories() did a full collection read AFTER fetchAllGigs()
  // — that was a redundant 3rd network call during home load.
  // Now call buildCategoriesFromGigs() with the list you already have.
  // ══════════════════════════════════════════════════════════════════════════

  List<String> buildCategoriesFromGigs(List<GigModel> gigs) {
    final cats = gigs
        .map((g) => g.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...cats];
  }

  // Kept for backward compatibility — now just wraps buildCategoriesFromGigs
  Future<List<String>> fetchCategories() async {
    try {
      final gigs = await fetchAllGigs();
      return buildCategoriesFromGigs(gigs);
    } on FirebaseException catch (e) {
      throw _handle(e, 'fetchCategories');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OTHER QUERIES
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
  // FIX: unawaited — fire and forget so it never touches the UI thread
  // ══════════════════════════════════════════════════════════════════════════

  void incrementViews(String gigId) {
    // Fire-and-forget. catchError discards PERMISSION_DENIED and any other
    // failure so Firestore never retries and never blocks the UI thread.
    _gigs
        .doc(gigId)
        .update({'totalViews': FieldValue.increment(1)})
        .catchError((_) {});
  }

  Exception _handle(FirebaseException e, String op) {
    final msg = switch (e.code) {
      'permission-denied'   => 'Access denied. Check Firestore rules.',
      'unavailable'         => 'Network unavailable. Please try again.',
      'not-found'           => 'Document not found.',
      'deadline-exceeded'   => 'Request timed out.',
      'failed-precondition' =>
        'Missing Firestore index. Open Firebase Console → Indexes.',
      _                     => 'Error in $op [${e.code}]: ${e.message}',
    };
    return Exception(msg);
  }
}