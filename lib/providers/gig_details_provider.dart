// lib/providers/gig_details_provider.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

import '../models/dr_model.dart';
import '../services/homegig_services.dart';

enum GigDetailsState { idle, loading, success, error }

class GigDetailsProvider extends ChangeNotifier {
  GigDetailsProvider({PatientGigService? service})
      : _service = service ?? PatientGigService.instance;

  final PatientGigService _service;

  // ── State ─────────────────────────────────────────────────────────────────
  GigDetailsState _state = GigDetailsState.idle;
  GigModel?       _gig;
  String?         _errorMessage;

  // Selected package index: 0 = Basic, 1 = Standard, 2 = Premium
  int _selectedPackageIndex = 0;

  // ── Getters ───────────────────────────────────────────────────────────────
  GigDetailsState get state            => _state;
  GigModel?       get gig              => _gig;
  String?         get errorMessage     => _errorMessage;
  bool            get isLoading        => _state == GigDetailsState.loading;
  bool            get hasError         => _state == GigDetailsState.error;
  int             get selectedPackageIndex => _selectedPackageIndex;

  GigPackage? get selectedPackage {
    if (_gig == null) return null;
    switch (_selectedPackageIndex) {
      case 1:  return _gig!.standardPackage;
      case 2:  return _gig!.premiumPackage;
      default: return _gig!.basicPackage;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD GIG — pass the gig directly (from list tap) to avoid a re-fetch
  // ══════════════════════════════════════════════════════════════════════════

  void setGig(GigModel gig) {
    _gig                  = gig;
    _state                = GigDetailsState.success;
    _selectedPackageIndex = 0;
    _errorMessage         = null;
    notifyListeners();

    // Fire-and-forget view counter — doesn't block the UI
    _service.incrementViews(gig.gigId);
  }

  // ── Optional: fetch fresh by ID (e.g. from a deep link) ───────────────────
  Future<void> loadGigById(String gigId) async {
    _state = GigDetailsState.loading;
    notifyListeners();
    try {
      final fetched = await _service.fetchById(gigId);
      if (fetched == null) {
        _errorMessage = 'This gig is no longer available.';
        _state        = GigDetailsState.error;
      } else {
        _gig                  = fetched;
        _selectedPackageIndex = 0;
        _state                = GigDetailsState.success;
        _service.incrementViews(gigId);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state        = GigDetailsState.error;
    }
    notifyListeners();
  }

  // ── Switch package tab (Basic / Standard / Premium) ───────────────────────
  void selectPackage(int index) {
    if (_selectedPackageIndex == index) return;
    _selectedPackageIndex = index;
    notifyListeners();
  }

  // ── Clear when leaving the screen ─────────────────────────────────────────
  void clear() {
    _gig                  = null;
    _state                = GigDetailsState.idle;
    _selectedPackageIndex = 0;
    _errorMessage         = null;
  }
}