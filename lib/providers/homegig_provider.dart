// lib/providers/homegig_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/dr_model.dart';
import '../services/homegig_services.dart';

enum GigLoadState { idle, loading, success, error }

class HomeGigProvider extends ChangeNotifier {
  HomeGigProvider({PatientGigService? service})
      : _service = service ?? PatientGigService.instance;

  final PatientGigService _service;

  // ── Gig state ─────────────────────────────────────────────────────────────
  GigLoadState   _state            = GigLoadState.idle;
  List<GigModel> _allGigs          = [];
  List<GigModel> _filteredGigs     = [];
  List<String>   _categories       = ['All'];
  String         _selectedCategory = 'All';
  String         _searchQuery      = '';
  String?        _errorMessage;

  // ── Patient profile state ─────────────────────────────────────────────────
  PatientModel?  _patient;
  bool           _patientLoading = false;

  StreamSubscription<List<GigModel>>?   _gigsSub;
  StreamSubscription<PatientModel?>?    _patientSub;

  // ── Getters ───────────────────────────────────────────────────────────────
  GigLoadState   get state            => _state;
  List<GigModel> get gigs             => _filteredGigs;
  List<String>   get categories       => _categories;
  String         get selectedCategory => _selectedCategory;
  String         get searchQuery      => _searchQuery;
  String?        get errorMessage     => _errorMessage;
  bool           get isLoading        => _state == GigLoadState.loading;
  bool           get hasError         => _state == GigLoadState.error;

  PatientModel?  get patient         => _patient;
  bool           get patientLoading  => _patientLoading;
  String         get patientName     => _patient?.fullName   ?? '';
  String         get patientFirstName => _patient?.firstName ?? 'there';
  String?        get patientImageUrl => _patient?.imageUrl;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT — called once from HomeView.initState
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialise() async {
    _listenToPatient();   // real-time patient profile
    await loadGigs();     // load all gigs
    _loadCategories();    // non-blocking category list
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PATIENT PROFILE — real-time listener from 'patients' collection
  // ══════════════════════════════════════════════════════════════════════════

  void _listenToPatient() {
    _patientSub?.cancel();
    _patientLoading = true;
    notifyListeners();

    _patientSub = _service.streamCurrentPatient().listen(
      (patient) {
        _patient        = patient;
        _patientLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _patientLoading = false;
        notifyListeners();
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ALL GIGS — no status filter
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadGigs() async {
    _setState(GigLoadState.loading);
    try {
      _allGigs = await _service.fetchAllGigs();
      _applyFilters();
      _setState(GigLoadState.success);
    } catch (e) {
      _errorMessage = _clean(e);
      _setState(GigLoadState.error);
    }
  }

  // ── Real-time stream (optional alternative to loadGigs) ───────────────────
  void subscribeToGigs() {
    _gigsSub?.cancel();
    _setState(GigLoadState.loading);
    _gigsSub = _service.streamAllGigs().listen(
      (gigs) {
        _allGigs = gigs;
        _applyFilters();
        _setState(GigLoadState.success);
      },
      onError: (Object e) {
        _errorMessage = _clean(e);
        _setState(GigLoadState.error);
      },
    );
  }

  void cancelGigsSubscription() {
    _gigsSub?.cancel();
    _gigsSub = null;
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Future<void> _loadCategories() async {
    try {
      _categories = await _service.fetchCategories();
      notifyListeners();
    } catch (_) {
      // Build client-side from loaded gigs as fallback
      if (_allGigs.isNotEmpty) {
        final cats = _allGigs
            .map((g) => g.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        _categories = ['All', ...cats];
        notifyListeners();
      }
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ── Category filter ───────────────────────────────────────────────────────
  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void resetFilters() {
    _searchQuery      = '';
    _selectedCategory = 'All';
    _applyFilters();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _applyFilters() {
    List<GigModel> result = List.from(_allGigs);

    // Category filter
    if (_selectedCategory != 'All') {
      result = result
          .where((g) =>
              g.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // Search filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result
          .where((g) =>
              g.title.toLowerCase().contains(q)        ||
              g.drName.toLowerCase().contains(q)       ||
              g.drSpecialty.toLowerCase().contains(q)  ||
              g.category.toLowerCase().contains(q)     ||
              g.subcategory.toLowerCase().contains(q)  ||
              g.description.toLowerCase().contains(q)  ||
              g.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    _filteredGigs = result;
  }

  void _setState(GigLoadState s) {
    _state = s;
    notifyListeners();
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _gigsSub?.cancel();
    _patientSub?.cancel();
    super.dispose();
  }
}