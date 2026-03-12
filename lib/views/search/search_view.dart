import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookdr/core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH VIEW  ·  CareSync Patients App
// Place at: lib/views/search/search_view.dart
// ══════════════════════════════════════════════════════════════════════════════

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();
  bool  _isFocused  = false;
  bool  _hasQuery   = false;
  String _query     = '';

  // Filters
  String _selectedSpecialty  = 'All';
  String _selectedAvailability = 'Any Time';
  String _selectedGender     = 'Any';
  String _selectedFee        = 'Any';
  RangeValues _feeRange      = const RangeValues(0, 5000);
  double _minRating          = 0;

  // Sort
  String _sortBy = 'Relevance';

  // Filter panel
  bool _showFilters = false;

  late AnimationController _filterCtrl;
  late Animation<double>   _filterAnim;

  // ── Static Data ───────────────────────────────────────────────────────────
  static const _specialties = [
    'All', 'Cardiologist', 'Neurologist', 'Orthopedic',
    'Dermatologist', 'Pediatrician', 'Dentist', 'Psychiatrist',
    'Gynecologist', 'ENT', 'Ophthalmologist', 'Urologist',
  ];

  static const _specialtyIcons = {
    'All':           Icons.grid_view_rounded,
    'Cardiologist':  Icons.favorite_rounded,
    'Neurologist':   Icons.psychology_rounded,
    'Orthopedic':    Icons.accessibility_new_rounded,
    'Dermatologist': Icons.face_rounded,
    'Pediatrician':  Icons.child_care_rounded,
    'Dentist':       Icons.medical_services_rounded,
    'Psychiatrist':  Icons.self_improvement_rounded,
    'Gynecologist':  Icons.pregnant_woman_rounded,
    'ENT':           Icons.hearing_rounded,
    'Ophthalmologist': Icons.remove_red_eye_rounded,
    'Urologist':     Icons.health_and_safety_rounded,
  };

  static const _availability = ['Any Time', 'Today', 'Tomorrow', 'This Week', 'Weekend'];
  static const _genders      = ['Any', 'Male', 'Female'];
  static const _sortOptions  = ['Relevance', 'Rating', 'Lowest Fee', 'Most Reviews', 'Nearest'];

  static const _recentSearches = [
    'Cardiologist near me',
    'Dr. Ahmed Khan',
    'Child fever consultation',
    'ECG report review',
    'Online dermatologist',
  ];

  static const _trendingSearches = [
    'Diabetes specialist',
    'Video consultation',
    'PMDC verified doctors',
    'Orthopedic surgeon',
    'Mental health',
    'Women\'s health',
  ];

  static const List<_Doctor> _allDoctors = [
    _Doctor('Dr. Ahmed Khan',    'Cardiologist',    4.9, 1240, true,  800,  'Online',   'm'),
    _Doctor('Dr. Sara Malik',    'Neurologist',     4.8,  980, true,  1200, 'Today',    'f'),
    _Doctor('Dr. Usman Ali',     'Orthopedic',      4.7,  760, false, 600,  'Tomorrow', 'm'),
    _Doctor('Dr. Ayesha Noor',   'Dermatologist',   4.9, 1120, true,  900,  'Online',   'f'),
    _Doctor('Dr. Bilal Raza',    'Pediatrician',    4.6,  540, false, 500,  'Today',    'm'),
    _Doctor('Dr. Hina Shahid',   'Dentist',         4.8,  890, true,  700,  'Online',   'f'),
    _Doctor('Dr. Kamran Siddiq', 'Psychiatrist',    4.7,  430, true,  1500, 'Tomorrow', 'm'),
    _Doctor('Dr. Nadia Pervaiz', 'Gynecologist',    4.9,  670, true,  1100, 'Today',    'f'),
    _Doctor('Dr. Tariq Mehmood', 'ENT',             4.5,  320, false, 550,  'This Week','m'),
    _Doctor('Dr. Zara Hassan',   'Ophthalmologist', 4.8,  510, true,  950,  'Online',   'f'),
  ];

  List<_Doctor> get _filteredDoctors {
    return _allDoctors.where((d) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q);
      final matchesSpec = _selectedSpecialty == 'All' ||
          d.specialty == _selectedSpecialty;
      final matchesGender = _selectedGender == 'Any' ||
          (_selectedGender == 'Male' && d.gender == 'm') ||
          (_selectedGender == 'Female' && d.gender == 'f');
      final matchesRating = d.rating >= _minRating;
      final matchesFee    = d.fee >= _feeRange.start && d.fee <= _feeRange.end;
      final matchesAvail  = _selectedAvailability == 'Any Time' ||
          d.availability == _selectedAvailability ||
          (_selectedAvailability == 'Today' && d.availability == 'Online');
      return matchesQuery && matchesSpec && matchesGender &&
          matchesRating && matchesFee && matchesAvail;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'Rating':        return b.rating.compareTo(a.rating);
          case 'Lowest Fee':    return a.fee.compareTo(b.fee);
          case 'Most Reviews':  return b.reviews.compareTo(a.reviews);
          default:              return 0;
        }
      });
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _searchCtrl.addListener(() {
      setState(() {
        _query    = _searchCtrl.text.trim();
        _hasQuery = _query.isNotEmpty;
      });
    });
    _filterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _filterAnim = CurvedAnimation(parent: _filterCtrl, curve: Curves.easeOutCubic);
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
    setState(() { _query = ''; _hasQuery = false; });
  }

  int get _activeFilterCount {
    int n = 0;
    if (_selectedSpecialty  != 'All')      n++;
    if (_selectedAvailability != 'Any Time') n++;
    if (_selectedGender     != 'Any')      n++;
    if (_minRating          > 0)           n++;
    if (_feeRange != const RangeValues(0, 5000)) n++;
    return n;
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          // Filter panel (animated)
          SizeTransition(
            sizeFactor: _filterAnim,
            child: _buildFilterPanel(),
          ),
          Expanded(
            child: _hasQuery
                ? _buildResults()
                : _buildDiscovery(),
          ),
        ]),
      ),
    );
  }

  // ── TOP BAR (header + search + specialty strip) ────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(children: [
        // Title row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Find a Doctor',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, letterSpacing: -0.5)),
                Text('${_allDoctors.length}+ specialists available',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            // Filter toggle button
            GestureDetector(
              onTap: _toggleFilters,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _showFilters || _activeFilterCount > 0
                      ? AppColors.primary
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _showFilters || _activeFilterCount > 0
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.tune_rounded,
                    color: _showFilters || _activeFilterCount > 0
                        ? Colors.white : AppColors.textSecondary,
                    size: 18),
                  if (_activeFilterCount > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                      child: Center(child: Text('$_activeFilterCount',
                        style: const TextStyle(fontSize: 10,
                          fontWeight: FontWeight.bold, color: AppColors.primary))),
                    ),
                  ],
                ]),
              ),
            ),
          ]),
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
                color: _isFocused ? AppColors.primary : Colors.transparent,
                width: 1.5),
              boxShadow: _isFocused ? [BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 12, offset: const Offset(0, 3))] : [],
            ),
            child: Row(children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded,
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                size: 20),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: _searchCtrl,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Doctor name, specialty, symptom...',
                  hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  border: InputBorder.none, isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14)),
              )),
              if (_hasQuery)
                GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.mediumGray.withOpacity(0.3),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 14),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.mic_rounded,
                      color: AppColors.primary, size: 16),
                  ),
                ),
            ]),
          ),
        ),

        // Specialty horizontal chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            itemCount: _specialties.length,
            itemBuilder: (_, i) {
              final sel = _selectedSpecialty == _specialties[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedSpecialty = _specialties[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.primary : Colors.transparent),
                    boxShadow: sel ? [BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 2))] : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _specialtyIcons[_specialties[i]] ?? Icons.medical_services_rounded,
                      size: 13,
                      color: sel ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(_specialties[i], style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.textSecondary)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ]),
    );
  }

  // ── FILTER PANEL (collapsible) ─────────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(color: AppColors.borderGray, height: 1),
        const SizedBox(height: 14),

        // Availability
        _filterLabel('Availability'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _availability.map((a) {
          final sel = _selectedAvailability == a;
          return _filterChip(a, sel,
            onTap: () => setState(() => _selectedAvailability = a));
        }).toList()),
        const SizedBox(height: 14),

        // Gender + Sort row
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _filterLabel('Gender'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _genders.map((g) {
              final sel = _selectedGender == g;
              return _filterChip(g, sel,
                onTap: () => setState(() => _selectedGender = g));
            }).toList()),
          ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _filterLabel('Sort By'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy, isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  items: _sortOptions.map((s) =>
                      DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ),
            ),
          ])),
        ]),
        const SizedBox(height: 14),

        // Fee range
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _filterLabel('Consultation Fee'),
          Text('PKR ${_feeRange.start.toInt()} – ${_feeRange.end.toInt()}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
              color: AppColors.primary)),
        ]),
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
            min: 0, max: 5000, divisions: 50,
            onChanged: (v) => setState(() => _feeRange = v),
          ),
        ),
        const SizedBox(height: 8),

        // Min rating
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _filterLabel('Minimum Rating'),
          Text(_minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+ ⭐',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
              color: AppColors.primary)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.warning,
            inactiveTrackColor: AppColors.borderGray,
            thumbColor: AppColors.warning,
            overlayColor: AppColors.warning.withOpacity(0.15),
            trackHeight: 3,
          ),
          child: Slider(
            value: _minRating, min: 0, max: 5, divisions: 10,
            onChanged: (v) => setState(() => _minRating = v),
          ),
        ),
        const SizedBox(height: 10),

        // Action buttons
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() {
              _selectedSpecialty    = 'All';
              _selectedAvailability = 'Any Time';
              _selectedGender       = 'Any';
              _sortBy               = 'Relevance';
              _feeRange             = const RangeValues(0, 5000);
              _minRating            = 0;
            }),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Reset All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary))),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: GestureDetector(
            onTap: _toggleFilters,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8, offset: const Offset(0, 3))]),
              child: Center(child: Text(
                'Apply${_activeFilterCount > 0 ? ' ($_activeFilterCount filters)' : ''}',
                style: const TextStyle(color: Colors.white,
                  fontSize: 13, fontWeight: FontWeight.bold))),
            ),
          )),
        ]),
      ]),
    );
  }

  // ── DISCOVERY (no query) ──────────────────────────────────────────────────
  Widget _buildDiscovery() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Searches', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            GestureDetector(
              onTap: () {},
              child: const Text('Clear All', style: TextStyle(
                fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 12),
          ..._recentSearches.map((s) => _recentItem(s)),
          const SizedBox(height: 24),
        ],

        // Trending
        const Text('Trending Searches', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 10, children: _trendingSearches.map((t) {
          return GestureDetector(
            onTap: () {
              _searchCtrl.text = t;
              setState(() { _query = t; _hasQuery = true; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderGray),
                boxShadow: AppColors.subtleShadow,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.trending_up_rounded,
                  color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(t, style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500)),
              ]),
            ),
          );
        }).toList()),
        const SizedBox(height: 30),

        // Browse by Specialty grid
        const Text('Browse by Specialty', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: _specialties.length - 1, // skip 'All'
          itemBuilder: (_, i) {
            final spec  = _specialties[i + 1];
            final icon  = _specialtyIcons[spec] ?? Icons.medical_services_rounded;
            final colors = [
              [AppColors.primaryExtraLight, AppColors.primary],
              [AppColors.infoLight,         AppColors.info],
              [AppColors.successLight,      AppColors.success],
              [AppColors.warningLight,      AppColors.warning],
              [const Color(0xFFF5EEF8),     const Color(0xFF9B59B6)],
              [const Color(0xFFE8F8F5),     const Color(0xFF1ABC9C)],
            ];
            final c = colors[i % colors.length];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedSpecialty = spec);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: c[0], borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: (c[1] as Color).withOpacity(0.2)),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle),
                    child: Icon(icon, color: c[1] as Color, size: 22)),
                  const SizedBox(height: 8),
                  Text(spec, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                      color: c[1] as Color)),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }

  // ── RESULTS ───────────────────────────────────────────────────────────────
  Widget _buildResults() {
    final docs = _filteredDoctors;
    return Column(children: [
      // Results count + sort row
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: Row(children: [
          Expanded(child: RichText(text: TextSpan(children: [
            TextSpan(text: '${docs.length} ', style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
            TextSpan(text: 'doctor${docs.length != 1 ? 's' : ''} found',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            if (_query.isNotEmpty)
              TextSpan(text: ' for "$_query"',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ]))),
          GestureDetector(
            onTap: _toggleFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightGray, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.sort_rounded, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                Text(_sortBy, style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),

      // Results list
      Expanded(child: docs.isEmpty
          ? _emptyState()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              itemCount: docs.length,
              itemBuilder: (_, i) => _SearchDoctorCard(doctor: docs[i]),
            )),
    ]);
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight, shape: BoxShape.circle),
          child: const Icon(Icons.search_off_rounded,
            color: AppColors.primary, size: 44)),
        const SizedBox(height: 20),
        const Text('No Doctors Found', style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text(
          'Try adjusting your search or filters to find what you\'re looking for.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() {
            _clearSearch();
            _selectedSpecialty    = 'All';
            _selectedAvailability = 'Any Time';
            _selectedGender       = 'Any';
            _feeRange             = const RangeValues(0, 5000);
            _minRating            = 0;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 3))]),
            child: const Text('Reset Search & Filters', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      ]),
    ),
  );

  // ── HELPER WIDGETS ────────────────────────────────────────────────────────
  Widget _recentItem(String text) => GestureDetector(
    onTap: () {
      _searchCtrl.text = text;
      setState(() { _query = text; _hasQuery = true; });
    },
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.history_rounded, color: AppColors.textTertiary, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(text, style: const TextStyle(
            fontSize: 13, color: AppColors.textPrimary)))),
        const Icon(Icons.north_west_rounded, color: AppColors.textTertiary, size: 14),
      ]),
    ),
  );

  Widget _filterChip(String label, bool selected, {required VoidCallback onTap}) =>
    GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent),
          boxShadow: selected ? [BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );

  Widget _filterLabel(String t) => Text(t, style: const TextStyle(
    fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary));
}

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH RESULT DOCTOR CARD
// ══════════════════════════════════════════════════════════════════════════════

class _SearchDoctorCard extends StatelessWidget {
  final _Doctor doctor;
  const _SearchDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final avColor = doctor.availability == 'Online'
        ? AppColors.successLight
        : doctor.availability == 'Today'
            ? AppColors.infoLight
            : AppColors.lightGray;
    final avText = doctor.availability == 'Online'
        ? AppColors.success
        : doctor.availability == 'Today'
            ? AppColors.info
            : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Avatar
            Stack(children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primaryExtraLight),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network('https://via.placeholder.com/100',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      doctor.gender == 'f'
                          ? Icons.person_rounded
                          : Icons.person_rounded,
                      color: AppColors.primary, size: 38)),
                ),
              ),
              // Online dot
              if (doctor.availability == 'Online')
                Positioned(bottom: 4, right: 4, child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                )),
            ]),
            const SizedBox(width: 14),

            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Name + verified
              Row(children: [
                Expanded(child: Text(doctor.name, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary))),
                if (doctor.verified) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight, borderRadius: BorderRadius.circular(7)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_rounded, color: AppColors.success, size: 10),
                    SizedBox(width: 3),
                    Text('Verified', style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ]),
                ),
              ]),
              const SizedBox(height: 3),
              Text(doctor.specialty, style: const TextStyle(
                fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),

              // Rating + reviews + fee
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
                const SizedBox(width: 3),
                Text('${doctor.rating}', style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('  (${doctor.reviews})', style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
                const Spacer(),
                Text('PKR ${doctor.fee}', style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 6),

              // Availability badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: avColor, borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    doctor.availability == 'Online'
                        ? Icons.circle
                        : Icons.calendar_today_rounded,
                    color: avText, size: 9),
                  const SizedBox(width: 4),
                  Text(
                    doctor.availability == 'Online'
                        ? 'Online Now'
                        : 'Available ${doctor.availability}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                      color: avText)),
                ]),
              ),
            ])),
          ]),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderGray),
          const SizedBox(height: 12),

          // Action buttons
          Row(children: [
            Expanded(child: _btn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Message',
              color: AppColors.primary,
              bg: AppColors.primaryExtraLight,
              onTap: () => HapticFeedback.selectionClick(),
            )),
            const SizedBox(width: 8),
            Expanded(child: _btn(
              icon: Icons.videocam_outlined,
              label: 'Video Call',
              color: AppColors.info,
              bg: AppColors.infoLight,
              onTap: () => HapticFeedback.selectionClick(),
            )),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6, offset: const Offset(0, 2))]),
                child: const Center(child: Text('Book Now', style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 38,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(
          color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ══════════════════════════════════════════════════════════════════════════════

class _Doctor {
  final String name, specialty, availability, gender;
  final double rating;
  final int reviews, fee;
  final bool verified;

  const _Doctor(this.name, this.specialty, this.rating, this.reviews,
      this.verified, this.fee, this.availability, this.gender);
}