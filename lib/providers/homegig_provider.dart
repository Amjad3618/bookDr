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

  GigLoadState   _state            = GigLoadState.idle;
  List<GigModel> _allGigs          = [];
  List<GigModel> _filteredGigs     = [];
  List<String>   _categories       = ['All'];
  String         _selectedCategory = 'All';
  String         _searchQuery      = '';
  String?        _errorMessage;

  PatientModel?  _patient;
  bool           _patientLoading   = false;

  StreamSubscription<List<GigModel>>? _gigsSub;
  StreamSubscription<PatientModel?>?  _patientSub;

  GigLoadState   get state             => _state;
  List<GigModel> get gigs              => _filteredGigs;
  List<String>   get categories        => _categories;
  String         get selectedCategory  => _selectedCategory;
  String         get searchQuery       => _searchQuery;
  String?        get errorMessage      => _errorMessage;
  bool           get isLoading         => _state == GigLoadState.loading;
  bool           get hasError          => _state == GigLoadState.error;
  PatientModel?  get patient           => _patient;
  bool           get patientLoading    => _patientLoading;
  String         get patientName       => _patient?.fullName   ?? '';
  String         get patientFirstName  => _patient?.firstName  ?? 'there';
  String?        get patientImageUrl   => _patient?.imageUrl;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT
  // FIX: loadGigs() now builds categories from the same response —
  // no extra Firestore call for categories.
  // Patient listener is fire-and-forget (non-blocking).
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialise() async {
    _listenToPatient();   // non-blocking real-time listener
    await loadGigs();     // single fetch, builds categories internally
  }

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
  // LOAD GIGS
  // FIX: Categories are built from the same list — no second network call.
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadGigs() async {
    _setState(GigLoadState.loading);
    try {
      _allGigs    = await _service.fetchAllGigs();
      _categories = _service.buildCategoriesFromGigs(_allGigs);
      _applyFilters();
      _setState(GigLoadState.success);
    } catch (e) {
      _errorMessage = _clean(e);
      _setState(GigLoadState.error);
    }
  }

  void subscribeToGigs() {
    _gigsSub?.cancel();
    _setState(GigLoadState.loading);
    _gigsSub = _service.streamAllGigs().listen(
      (gigs) {
        _allGigs    = gigs;
        _categories = _service.buildCategoriesFromGigs(gigs);
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

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

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

  void _applyFilters() {
    List<GigModel> result = List.from(_allGigs);

    if (_selectedCategory != 'All') {
      result = result
          .where((g) =>
              g.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result
          .where((g) =>
              g.title.toLowerCase().contains(q)       ||
              g.drName.toLowerCase().contains(q)      ||
              g.drSpecialty.toLowerCase().contains(q) ||
              g.category.toLowerCase().contains(q)    ||
              g.subcategory.toLowerCase().contains(q) ||
              g.description.toLowerCase().contains(q) ||
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