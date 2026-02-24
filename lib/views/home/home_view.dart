import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bookdr/core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// HOME VIEW  ·  CareSync Patients App
// Place at: lib/views/home/home_view.dart
// ══════════════════════════════════════════════════════════════════════════════

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;
  int _activeBanner = 0;
  final _bannerPage = PageController();

  // ── Static data ───────────────────────────────────────────────────────────
  static const _categories = [
    _Cat('All',           Icons.grid_view_rounded),
    _Cat('Cardiologist',  Icons.favorite_rounded),
    _Cat('Neurologist',   Icons.psychology_rounded),
    _Cat('Orthopedic',    Icons.accessibility_new_rounded),
    _Cat('Dermatologist', Icons.face_rounded),
    _Cat('Pediatrician',  Icons.child_care_rounded),
    _Cat('Dentist',       Icons.medical_services_rounded),
  ];

  static const _doctors = [
    _Doctor('Dr. Ahmed Khan',  'Cardiologist',    4.9, 1240, true),
    _Doctor('Dr. Sara Malik',  'Neurologist',     4.8,  980, true),
    _Doctor('Dr. Usman Ali',   'Orthopedic',      4.7,  760, false),
    _Doctor('Dr. Ayesha Noor', 'Dermatologist',   4.9, 1120, true),
    _Doctor('Dr. Bilal Raza',  'Pediatrician',    4.6,  540, false),
    _Doctor('Dr. Hina Shahid', 'Dentist',         4.8,  890, true),
  ];

  static const _banners = [
    _BannerData('Book Your First\nConsultation Free!',
        'Use code FIRST100 at checkout',
        Icons.local_offer_rounded, Color(0xFFE67E22), Color(0xFFD35400)),
    _BannerData('Video Consultation\nAvailable 24/7',
        'Connect with top doctors anytime',
        Icons.videocam_rounded, Color(0xFF3498DB), Color(0xFF2980B9)),
    _BannerData('Your Health Reports\nIn One Place',
        'Manage all your records easily',
        Icons.folder_shared_rounded, Color(0xFF27AE60), Color(0xFF1E8449)),
  ];

  static const _services = [
    _Svc('Video\nConsult',  Icons.videocam_rounded,          Color(0xFFE67E22), Color(0xFFFEEBD8)),
    _Svc('Book\nClinic',    Icons.local_hospital_rounded,    Color(0xFF3498DB), Color(0xFFEBF5FB)),
    _Svc('Lab\nTests',      Icons.biotech_rounded,           Color(0xFF27AE60), Color(0xFFD5F4E6)),
    _Svc('My\nReports',     Icons.description_rounded,       Color(0xFF9B59B6), Color(0xFFF5EEF8)),
    _Svc('Pharmacy',        Icons.local_pharmacy_rounded,    Color(0xFFE74C3C), Color(0xFFFDEDEB)),
    _Svc('Ambulance',       Icons.emergency_rounded,         Color(0xFFF39C12), Color(0xFFFEEBD8)),
    _Svc('Health\nBlog',    Icons.article_rounded,           Color(0xFF1ABC9C), Color(0xFFE8F8F5)),
    _Svc('Near\nMe',        Icons.near_me_rounded,           Color(0xFF2C3E50), Color(0xFFEAECEE)),
  ];

  static const _hospitals = [
    _Hospital('City Hospital',     '4.8', '0.8 km', Color(0xFFFEEBD8), Color(0xFFE67E22)),
    _Hospital('Medicare Clinic',   '4.6', '1.2 km', Color(0xFFEBF5FB), Color(0xFF3498DB)),
    _Hospital('Al-Shifa Hospital', '4.9', '2.1 km', Color(0xFFD5F4E6), Color(0xFF27AE60)),
    _Hospital('Care Center',       '4.7', '3.4 km', Color(0xFFFEEBD8), Color(0xFFF39C12)),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoBanner();
  }

  void _startAutoBanner() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) break;
      final next = (_activeBanner + 1) % _banners.length;
      _bannerPage.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _bannerPage.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildBanner()),
            SliverToBoxAdapter(child: _buildUpcomingCard()),
            SliverToBoxAdapter(child: _buildQuickServices()),
            SliverToBoxAdapter(child: _buildCategoryBar()),
            SliverToBoxAdapter(child: _buildTopDoctors()),
            SliverToBoxAdapter(child: _buildNearbyHospitals()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning 👋'
        : hour < 17 ? 'Good Afternoon 👋'
        : 'Good Evening 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(children: [
        // Avatar with orange border
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            color: AppColors.primaryExtraLight,
          ),
          child: ClipOval(
            child: Image.network(
              'https://via.placeholder.com/100',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Name + greeting
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const Text('Ali Raza Hassan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.textPrimary)),
        ])),

        // Notification button
        _iconBtn(Icons.notifications_outlined, badge: true, onTap: () {}),
        const SizedBox(width: 10),

        // Support button
        _iconBtn(Icons.headset_mic_rounded, badge: false, onTap: () {}),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required bool badge, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: AppColors.subtleShadow),
        child: Stack(alignment: Alignment.center, children: [
          Icon(icon, color: AppColors.textSecondary, size: 21),
          if (badge)
            Positioned(top: 8, right: 8, child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.error, shape: BoxShape.circle))),
        ]),
      ),
    );

  // ── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: AppColors.subtleShadow),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.6), fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18)),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Mic button
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.orangeGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4))]),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
        ),
      ]),
    );
  }

  // ── PROMO BANNER (auto-scroll) ────────────────────────────────────────────
  Widget _buildBanner() {
    return Column(children: [
      SizedBox(
        height: 150,
        child: PageView.builder(
          controller: _bannerPage,
          onPageChanged: (i) => setState(() => _activeBanner = i),
          itemCount: _banners.length,
          itemBuilder: (_, i) {
            final b = _banners[i];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [b.c1, b.c2],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(
                  color: b.c1.withOpacity(0.35), blurRadius: 18,
                  offset: const Offset(0, 6))]),
              child: Stack(children: [
                Positioned(top: -20, right: -20, child: _bubble(110, 0.09)),
                Positioned(top: 20, right: 35,   child: _bubble(55,  0.07)),
                Positioned(bottom: -30, right: 70,child: _bubble(75,  0.05)),
                Positioned(right: 16, bottom: 8,
                  child: Icon(b.icon, color: Colors.white.withOpacity(0.22), size: 85)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 100, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b.title, style: const TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.bold, height: 1.25)),
                      const SizedBox(height: 5),
                      Text(b.subtitle, style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 11)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text('Book Now', style: TextStyle(
                          color: b.c1, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                ),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      // Dot indicators
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_banners.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _activeBanner == i ? 18 : 6, height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _activeBanner == i ? AppColors.primary : AppColors.borderGray),
        ))),
      const SizedBox(height: 22),
    ]);
  }

  // ── UPCOMING APPOINTMENT CARD ──────────────────────────────────────────────
  Widget _buildUpcomingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionRow('Upcoming Appointment', onSeeAll: () {}),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 18, offset: const Offset(0, 6))]),
          child: Stack(children: [
            Positioned(top: -15, right: -15, child: _bubble(80, 0.09)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                // Doctor avatar
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.35), width: 2)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Dr. Ahmed Khan', style: TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Cardiologist  ·  Online Now',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Column(children: [
                    Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                    SizedBox(height: 2),
                    Text('Video', style: TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              // Date + time chips
              Row(children: [
                _chip(Icons.calendar_today_rounded, 'Mon, 24 Feb 2025'),
                const SizedBox(width: 8),
                _chip(Icons.access_time_rounded, '10:30 AM'),
              ]),
              const SizedBox(height: 14),
              // Action buttons
              Row(children: [
                Expanded(child: _outlineBtn('Reschedule', onTap: () {})),
                const SizedBox(width: 10),
                Expanded(child: _solidBtn('Join Now', onTap: () {})),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(9)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 11),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ]),
  );

  Widget _outlineBtn(String label, {required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: Colors.white.withOpacity(0.5))),
        child: Center(child: Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      ),
    );

  Widget _solidBtn(String label, {required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(11)),
        child: Center(child: Text(label, style: const TextStyle(
          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))),
      ),
    );

  // ── QUICK SERVICES ────────────────────────────────────────────────────────
  Widget _buildQuickServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionRow('Quick Services', onSeeAll: null),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14, crossAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: _services.length,
          itemBuilder: (_, i) {
            final s = _services[i];
            return GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Column(children: [
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    color: s.bg, borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(
                      color: s.color.withOpacity(0.2),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Icon(s.icon, color: s.color, size: 26),
                ),
                const SizedBox(height: 6),
                Text(s.label, textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary, height: 1.2)),
              ]),
            );
          },
        ),
        const SizedBox(height: 26),
      ]),
    );
  }

  // ── SPECIALTY CATEGORY BAR ────────────────────────────────────────────────
  Widget _buildCategoryBar() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _sectionRow('Find a Specialist', onSeeAll: () {}),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final sel = _selectedCategory == i;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.borderGray),
                  boxShadow: sel ? [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8, offset: const Offset(0, 3))] : [],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_categories[i].icon,
                    color: sel ? Colors.white : AppColors.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text(_categories[i].label, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.textSecondary)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 18),
    ]);
  }

  // ── TOP DOCTORS LIST ──────────────────────────────────────────────────────
  Widget _buildTopDoctors() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionRow('Top Doctors', onSeeAll: () {}),
        const SizedBox(height: 14),
        ...List.generate(_doctors.length,
          (i) => _DoctorCard(doctor: _doctors[i])),
        const SizedBox(height: 26),
      ]),
    );
  }

  // ── NEARBY HOSPITALS ──────────────────────────────────────────────────────
  Widget _buildNearbyHospitals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionRow('Nearby Hospitals', onSeeAll: () {}),
        const SizedBox(height: 14),
        SizedBox(
          height: 166,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hospitals.length,
            itemBuilder: (_, i) {
              final h = _hospitals[i];
              return Container(
                width: 158,
                margin: EdgeInsets.only(right: i < _hospitals.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderGray),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: h.bg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.local_hospital_rounded, color: h.ic, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(h.name, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 12),
                    const SizedBox(width: 3),
                    Text(h.rating, style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
                    Text('  ·  ${h.dist}', style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(9)),
                    child: const Text('Get Directions', style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _sectionRow(String title, {required VoidCallback? onSeeAll}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      if (onSeeAll != null)
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('See All', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
    ],
  );

  Widget _bubble(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DOCTOR CARD
// ══════════════════════════════════════════════════════════════════════════════

class _DoctorCard extends StatelessWidget {
  final _Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(children: [
        // Avatar with online dot
        Stack(children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.primaryExtraLight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network('https://via.placeholder.com/100',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person_rounded, color: AppColors.primary, size: 36)),
            ),
          ),
          Positioned(bottom: 4, right: 4, child: Container(
            width: 13, height: 13,
            decoration: BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2)),
          )),
        ]),
        const SizedBox(width: 14),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name + verified badge
          Row(children: [
            Expanded(child: Text(doctor.name, style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold,
              color: AppColors.textPrimary))),
            if (doctor.verified) Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successLight, borderRadius: BorderRadius.circular(8)),
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
            fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 5),
          // Rating + reviews
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
            const SizedBox(width: 3),
            Text('${doctor.rating}', style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text('  (${doctor.reviews} reviews)', style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 9),
          // Action buttons
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6, offset: const Offset(0, 2))]),
                child: const Center(child: Text('Book Now', style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            )),
            const SizedBox(width: 8),
            // Chat
            _actionIcon(Icons.chat_bubble_outline_rounded,
              AppColors.primary, AppColors.primaryExtraLight),
            const SizedBox(width: 8),
            // Video
            _actionIcon(Icons.videocam_outlined,
              AppColors.info, AppColors.infoLight),
          ]),
        ])),
      ]),
    );
  }

  Widget _actionIcon(IconData icon, Color color, Color bg) => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Icon(icon, color: color, size: 16),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════

class _Cat {
  final String label; final IconData icon;
  const _Cat(this.label, this.icon);
}

class _Doctor {
  final String name, specialty;
  final double rating;
  final int reviews;
  final bool verified;
  const _Doctor(this.name, this.specialty, this.rating, this.reviews, this.verified);
}

class _BannerData {
  final String title, subtitle;
  final IconData icon;
  final Color c1, c2;
  const _BannerData(this.title, this.subtitle, this.icon, this.c1, this.c2);
}

class _Svc {
  final String label; final IconData icon; final Color color, bg;
  const _Svc(this.label, this.icon, this.color, this.bg);
}

class _Hospital {
  final String name, rating, dist;
  final Color bg, ic;
  const _Hospital(this.name, this.rating, this.dist, this.bg, this.ic);
}