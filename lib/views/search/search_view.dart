// lib/views/search/search_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bookdr/core/theme/app_colors.dart';

import '../../models/fetch_de_model.dart';
import '../../providers/fetch_dr_provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();

  bool   _isFocused   = false;
  bool   _showFilters = false;

  // ── Active filters ────────────────────────────────────────────────────────
  String      _selectedSpecialty   = 'All';
  String      _selectedGender      = 'Any';
  String      _selectedAvailability = 'Any';
  RangeValues _feeRange            = const RangeValues(0, 10000);
  double      _minRating           = 0;
  String      _sortBy              = 'Rating';

  late AnimationController _filterCtrl;
  late Animation<double>   _filterAnim;

  // ── Static options ────────────────────────────────────────────────────────
  static const _genders      = ['Any', 'Male', 'Female'];
  static const _availability = ['Any', 'Online', 'Offline'];
  static const _sortOptions  = [
    'Rating',
    'Most Reviews',
    'Lowest Fee',
    'Highest Fee',
    'Experience',
  ];

  static const _specialtyIcons = <String, IconData>{
    'All':              Icons.grid_view_rounded,
    'General':          Icons.local_hospital_rounded,
    'Cardiologist':     Icons.favorite_rounded,
    'Neurologist':      Icons.psychology_rounded,
    'Orthopedic':       Icons.accessibility_new_rounded,
    'Dermatologist':    Icons.face_rounded,
    'Pediatrician':     Icons.child_care_rounded,
    'Dentist':          Icons.medical_services_rounded,
    'Psychiatrist':     Icons.self_improvement_rounded,
    'Gynecologist':     Icons.pregnant_woman_rounded,
    'ENT':              Icons.hearing_rounded,
    'Ophthalmologist':  Icons.remove_red_eye_rounded,
    'Urologist':        Icons.health_and_safety_rounded,
  };

  static const _recentSearches = [
    'Cardiologist',
    'Video consultation',
    'Dr. Ahmed',
    'Child specialist',
    'Skin doctor',
  ];

  static const _trendingSearches = [
    'Diabetes specialist',
    'PMDC verified',
    'Online consultation',
    'Mental health',
    'Women\'s health',
    'Orthopedic surgeon',
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
        () => setState(() => _isFocused = _focusNode.hasFocus));
    _searchCtrl.addListener(() => setState(() {}));

    _filterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _filterAnim =
        CurvedAnimation(parent: _filterCtrl, curve: Curves.easeOutCubic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().initialise();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _filterCtrl.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    _showFilters ? _filterCtrl.forward() : _filterCtrl.reverse();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    context.read<DoctorProvider>().onSearchChanged('');
    _focusNode.unfocus();
  }

  int get _activeFilterCount {
    int n = 0;
    if (_selectedSpecialty   != 'All')   n++;
    if (_selectedGender      != 'Any')   n++;
    if (_selectedAvailability != 'Any')  n++;
    if (_minRating            > 0)       n++;
    if (_feeRange != const RangeValues(0, 10000)) n++;
    return n;
  }

  // ── Client-side filtering on top of provider's list ───────────────────────
  List<fetchDoctorModel> _applyLocalFilters(List<fetchDoctorModel> input) {
    List<fetchDoctorModel> result = List.from(input);

    if (_selectedGender != 'Any') {
      // doctors collection doesn't have a gender field — skip silently
    }

    if (_selectedAvailability != 'Any') {
      final online = _selectedAvailability == 'Online';
      result = result.where((d) => d.isOnline == online).toList();
    }

    if (_minRating > 0) {
      result = result.where((d) => d.rating >= _minRating).toList();
    }

    result = result
        .where((d) =>
            d.consultationFee >= _feeRange.start &&
            d.consultationFee <= _feeRange.end)
        .toList();

    // Sort
    switch (_sortBy) {
      case 'Most Reviews':
        result.sort((a, b) => b.totalReviews.compareTo(a.totalReviews));
        break;
      case 'Lowest Fee':
        result.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'Highest Fee':
        result.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
      case 'Experience':
        result.sort(
            (a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
        break;
      case 'Rating':
      default:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return result;
  }

  void _resetFilters() {
    setState(() {
      _selectedSpecialty    = 'All';
      _selectedGender       = 'Any';
      _selectedAvailability = 'Any';
      _feeRange             = const RangeValues(0, 10000);
      _minRating            = 0;
      _sortBy               = 'Rating';
    });
    context.read<DoctorProvider>().resetFilters();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorProvider>(
      builder: (_, prov, __) {
        final hasQuery = _searchCtrl.text.trim().isNotEmpty;
        final displayed = _applyLocalFilters(prov.doctors);

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(prov),
                SizeTransition(
                  sizeFactor: _filterAnim,
                  child: _buildFilterPanel(prov),
                ),
                Expanded(
                  child: prov.isLoading
                      ? _buildSkeletons()
                      : prov.hasError
                          ? _buildError(prov)
                          : hasQuery || _activeFilterCount > 0
                              ? _buildResults(displayed, prov)
                              : _buildDiscovery(prov),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(DoctorProvider prov) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        children: [
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find a Doctor',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${prov.doctors.length} specialists available',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Filter button
                GestureDetector(
                  onTap: _toggleFilters,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _showFilters || _activeFilterCount > 0
                          ? AppColors.primary
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _showFilters || _activeFilterCount > 0
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          color: _showFilters || _activeFilterCount > 0
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                        if (_activeFilterCount > 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_activeFilterCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      _isFocused ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                      onChanged: (v) {
                        prov.onSearchChanged(v);
                        // also update specialty if empty
                        if (v.isEmpty) {
                          prov.selectSpecialty(_selectedSpecialty);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Doctor name, specialty, city...',
                        hintStyle: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary, size: 14),
                      ),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          ),

          // Specialty chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              itemCount: prov.specialties.length,
              itemBuilder: (_, i) {
                final spec = prov.specialties[i];
                final sel  = _selectedSpecialty == spec;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSpecialty = spec);
                    prov.selectSpecialty(spec);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                      ),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _specialtyIcons[spec] ??
                              Icons.medical_services_rounded,
                          size: 13,
                          color: sel
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          spec,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── FILTER PANEL ──────────────────────────────────────────────────────────
  Widget _buildFilterPanel(DoctorProvider prov) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.borderGray, height: 1),
          const SizedBox(height: 14),

          // Availability
          _filterLabel('Availability'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availability.map((a) {
              return _filterChip(
                a,
                _selectedAvailability == a,
                onTap: () =>
                    setState(() => _selectedAvailability = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Gender + Sort
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterLabel('Gender'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _genders.map((g) {
                        return _filterChip(
                          g,
                          _selectedGender == g,
                          onTap: () =>
                              setState(() => _selectedGender = g),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterLabel('Sort By'),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary),
                          items: _sortOptions
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _sortBy = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fee range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _filterLabel('Consultation Fee (PKR)'),
              Text(
                '${_feeRange.start.toInt()} – ${_feeRange.end.toInt()}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.borderGray,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.15),
              trackHeight: 3,
            ),
            child: RangeSlider(
              values: _feeRange,
              min: 0,
              max: 10000,
              divisions: 100,
              onChanged: (v) => setState(() => _feeRange = v),
            ),
          ),
          const SizedBox(height: 6),

          // Min rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _filterLabel('Minimum Rating'),
              Text(
                _minRating == 0
                    ? 'Any'
                    : '${_minRating.toStringAsFixed(1)}+ ⭐',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF59E0B),
              inactiveTrackColor: AppColors.borderGray,
              thumbColor: const Color(0xFFF59E0B),
              overlayColor:
                  const Color(0xFFF59E0B).withOpacity(0.15),
              trackHeight: 3,
            ),
            child: Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (v) => setState(() => _minRating = v),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Reset All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _toggleFilters,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Apply${_activeFilterCount > 0 ? ' ($_activeFilterCount)' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── DISCOVERY (empty search) ──────────────────────────────────────────────
  Widget _buildDiscovery(DoctorProvider prov) {
    final specs = prov.specialties.where((s) => s != 'All').toList();
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._recentSearches.map((s) => _recentItem(s, prov)),
          const SizedBox(height: 24),

          // Trending
          const Text(
            'Trending Searches',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _trendingSearches.map((t) {
              return GestureDetector(
                onTap: () {
                  _searchCtrl.text = t;
                  prov.onSearchChanged(t);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: AppColors.borderGray),
                    boxShadow: AppColors.subtleShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        t,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Browse by Specialty grid — built from real Firestore data
          const Text(
            'Browse by Specialty',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          specs.isEmpty
              ? const SizedBox.shrink()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: specs.length,
                  itemBuilder: (_, i) {
                    final spec = specs[i];
                    final icon = _specialtyIcons[spec] ??
                        Icons.medical_services_rounded;
                    final palette = [
                      [AppColors.primaryExtraLight, AppColors.primary],
                      [const Color(0xFFEFF6FF), const Color(0xFF2563EB)],
                      [const Color(0xFFF0FDF4), const Color(0xFF059669)],
                      [const Color(0xFFFEF3C7), const Color(0xFFD97706)],
                      [const Color(0xFFF5F3FF), const Color(0xFF7C3AED)],
                      [const Color(0xFFECFEFF), const Color(0xFF0891B2)],
                    ];
                    final c = palette[i % palette.length];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(
                            () => _selectedSpecialty = spec);
                        prov.selectSpecialty(spec);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: c[0],
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                              color: c[1].withOpacity(0.2)),
                          boxShadow: AppColors.subtleShadow,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon,
                                  color: c[1], size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              spec,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: c[1],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // ── RESULTS ───────────────────────────────────────────────────────────────
  Widget _buildResults(
      List<fetchDoctorModel> docs, DoctorProvider prov) {
    return Column(
      children: [
        // Count + sort row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${docs.length} ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(
                        text:
                            'doctor${docs.length != 1 ? 's' : ''} found',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _toggleFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded,
                          color: AppColors.textSecondary,
                          size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: docs.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: prov.refresh,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    itemCount: docs.length,
                    itemBuilder: (_, i) =>
                        _DoctorCard(doctor: docs[i]),
                  ),
                ),
        ),
      ],
    );
  }

  // ── SKELETON LOADER ───────────────────────────────────────────────────────
  Widget _buildSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      itemCount: 5,
      itemBuilder: (_, __) => const _DoctorCardSkeleton(),
    );
  }

  // ── ERROR STATE ───────────────────────────────────────────────────────────
  Widget _buildError(DoctorProvider prov) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              prov.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: prov.loadDoctors,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Doctors Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different name, specialty, or adjust your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _recentItem(String text, DoctorProvider prov) =>
      GestureDetector(
        onTap: () {
          _searchCtrl.text = text;
          prov.onSearchChanged(text);
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              const Icon(Icons.history_rounded,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ),
              const Icon(Icons.north_west_rounded,
                  color: AppColors.textSecondary, size: 14),
            ],
          ),
        ),
      );

  Widget _filterChip(String label, bool selected,
          {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.lightGray,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      );

  Widget _filterLabel(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// DOCTOR CARD
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final fetchDoctorModel doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.primaryExtraLight,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: doctor.profileImageUrl != null &&
                                doctor.profileImageUrl!.isNotEmpty
                            ? Image.network(
                                doctor.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.person_rounded,
                                        color: AppColors.primary,
                                        size: 36),
                              )
                            : const Icon(Icons.person_rounded,
                                color: AppColors.primary, size: 36),
                      ),
                    ),
                    // Online indicator
                    if (doctor.isOnline)
                      Positioned(
                        bottom: 3,
                        right: 3,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + verified
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (doctor.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius:
                                    BorderRadius.circular(7),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Color(0xFF059669),
                                      size: 10),
                                  SizedBox(width: 3),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Specialty
                      Text(
                        doctor.subSpecialty.isNotEmpty
                            ? '${doctor.specialty} · ${doctor.subSpecialty}'
                            : doctor.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Hospital + city
                      if (doctor.hospitalName.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.local_hospital_outlined,
                                size: 11,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                doctor.city.isNotEmpty
                                    ? '${doctor.hospitalName}, ${doctor.city}'
                                    : doctor.hospitalName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),

                      // Rating + experience + fee
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${doctor.totalReviews})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (doctor.yearsOfExperience > 0) ...[
                            const Icon(Icons.work_outline_rounded,
                                size: 11,
                                color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              '${doctor.yearsOfExperience}y exp',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            'PKR ${doctor.consultationFee.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bio snippet
            if (doctor.professionalBio.isNotEmpty) ...[
              Text(
                doctor.professionalBio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Divider(height: 1, color: AppColors.borderGray),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                // Online badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: doctor.isOnline
                        ? const Color(0xFFD1FAE5)
                        : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: doctor.isOnline
                              ? const Color(0xFF059669)
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        doctor.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: doctor.isOnline
                              ? const Color(0xFF059669)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _actionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  color: AppColors.primary,
                  bg: AppColors.primaryExtraLight,
                  onTap: () => HapticFeedback.selectionClick(),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => HapticFeedback.selectionClick(),
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// SKELETON CARD
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorCardSkeleton extends StatefulWidget {
  const _DoctorCardSkeleton();

  @override
  State<_DoctorCardSkeleton> createState() => _DoctorCardSkeletonState();
}

class _DoctorCardSkeletonState extends State<_DoctorCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sh(72, 72, r: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sh(14, 180),
                    const SizedBox(height: 8),
                    _sh(11, 120),
                    const SizedBox(height: 8),
                    _sh(10, 160),
                    const SizedBox(height: 8),
                    _sh(10, double.infinity),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _sh(32, 80, r: 8),
                        const SizedBox(width: 8),
                        _sh(32, 80, r: 8),
                        const Spacer(),
                        _sh(32, 100, r: 11),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sh(double h, double w, {double r = 6}) => Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: AppColors.borderGray,
          borderRadius: BorderRadius.circular(r),
        ),
      );
}