// lib/providers/doctor_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/fetch_de_model.dart';
import '../services/fetch_dr_services.dart';



enum DoctorLoadState { idle, loading, success, error }

class DoctorProvider extends ChangeNotifier {
  DoctorProvider({DoctorService? service})
      : _service = service ?? DoctorService.instance;

  final DoctorService _service;

  // ── State ─────────────────────────────────────────────────────────────────
  DoctorLoadState     _state            = DoctorLoadState.idle;
  List<fetchDoctorModel>   _allDoctors       = [];
  List<fetchDoctorModel>   _filteredDoctors  = [];
  List<String>        _specialties      = ['All'];
  String              _selectedSpecialty = 'All';
  String              _searchQuery      = '';
  String?             _errorMessage;
  StreamSubscription<List<fetchDoctorModel>>? _sub;

  // ── Getters ───────────────────────────────────────────────────────────────
  DoctorLoadState   get state             => _state;
  List<fetchDoctorModel> get doctors           => _filteredDoctors;
  List<String>      get specialties       => _specialties;
  String            get selectedSpecialty => _selectedSpecialty;
  String            get searchQuery       => _searchQuery;
  String?           get errorMessage      => _errorMessage;
  bool              get isLoading         => _state == DoctorLoadState.loading;
  bool              get hasError          => _state == DoctorLoadState.error;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT — called once from view's initState
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialise() async {
    await loadDoctors();
    _loadSpecialties(); // non-blocking
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD ALL DOCTORS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadDoctors() async {
    _setState(DoctorLoadState.loading);
    try {
      _allDoctors = await _service.fetchAllDoctors();
      _applyFilters();
      _setState(DoctorLoadState.success);
    } catch (e) {
      _errorMessage = _clean(e);
      _setState(DoctorLoadState.error);
    }
  }

  // ── Real-time stream (optional alternative to loadDoctors) ────────────────
  void subscribeToDoctors() {
    _sub?.cancel();
    _setState(DoctorLoadState.loading);
    _sub = _service.streamAllDoctors().listen(
      (doctors) {
        _allDoctors = doctors;
        _applyFilters();
        _setState(DoctorLoadState.success);
      },
      onError: (Object e) {
        _errorMessage = _clean(e);
        _setState(DoctorLoadState.error);
      },
    );
  }

  void cancelSubscription() {
    _sub?.cancel();
    _sub = null;
  }

  // ── Specialties metadata ──────────────────────────────────────────────────
  Future<void> _loadSpecialties() async {
    try {
      _specialties = await _service.fetchSpecialties();
      notifyListeners();
    } catch (_) {
      // Build client-side from already-loaded doctors as fallback
      if (_allDoctors.isNotEmpty) {
        final specs = _allDoctors
            .map((d) => d.specialty)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        _specialties = ['All', ...specs];
        notifyListeners();
      }
    }
  }

  // ── Search (client-side — instant feedback) ───────────────────────────────
  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ── Specialty filter ───────────────────────────────────────────────────────
  void selectSpecialty(String specialty) {
    if (_selectedSpecialty == specialty) return;
    _selectedSpecialty = specialty;
    _applyFilters();
    notifyListeners();
  }

  // ── Reset all filters ─────────────────────────────────────────────────────
  void resetFilters() {
    _searchQuery       = '';
    _selectedSpecialty = 'All';
    _applyFilters();
    notifyListeners();
  }

  // ── Refresh (pull-to-refresh) ──────────────────────────────────────────────
  Future<void> refresh() => loadDoctors();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _applyFilters() {
    List<fetchDoctorModel> result = List.from(_allDoctors);

    // Specialty filter
    if (_selectedSpecialty != 'All') {
      result = result
          .where((d) =>
              d.specialty.toLowerCase() == _selectedSpecialty.toLowerCase())
          .toList();
    }

    // Search filter — name, specialty, hospital, city
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result
          .where((d) =>
              d.fullName.toLowerCase().contains(q)      ||
              d.specialty.toLowerCase().contains(q)     ||
              d.subSpecialty.toLowerCase().contains(q)  ||
              d.hospitalName.toLowerCase().contains(q)  ||
              d.city.toLowerCase().contains(q))
          .toList();
    }

    _filteredDoctors = result;
  }

  void _setState(DoctorLoadState s) {
    _state = s;
    notifyListeners();
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}