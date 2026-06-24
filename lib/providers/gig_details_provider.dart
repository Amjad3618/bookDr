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

  GigDetailsState _state            = GigDetailsState.idle;
  GigModel?       _gig;
  String?         _errorMessage;
  int             _selectedPackageIndex = 0;

  GigDetailsState get state                => _state;
  GigModel?       get gig                  => _gig;
  String?         get errorMessage         => _errorMessage;
  bool            get isLoading            => _state == GigDetailsState.loading;
  bool            get hasError             => _state == GigDetailsState.error;
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
  // SET GIG
  // FIX: incrementViews is now void (fire-and-forget in the service layer)
  // so it never blocks this method or the UI thread.
  // This method itself is synchronous — safe to call before Navigator.push.
  // ══════════════════════════════════════════════════════════════════════════

  void setGig(GigModel gig) {
    _gig                  = gig;
    _state                = GigDetailsState.success;
    _selectedPackageIndex = 0;
    _errorMessage         = null;
    notifyListeners();

    // Fire-and-forget — void, never awaited, never blocks UI
    _service.incrementViews(gig.gigId);
  }

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

  void selectPackage(int index) {
    if (_selectedPackageIndex == index) return;
    _selectedPackageIndex = index;
    notifyListeners();
  }

  void clear() {
    _gig                  = null;
    _state                = GigDetailsState.idle;
    _selectedPackageIndex = 0;
    _errorMessage         = null;
  }
}