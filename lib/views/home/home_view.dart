// lib/views/home_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bookdr/core/theme/app_colors.dart';

import '../../models/dr_model.dart';
import '../../providers/homegig_provider.dart';
import '../../providers/gig_details_provider.dart';
import '../details_screens/gigs_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // ── Consultation type helpers ─────────────────────────────────────────────
  Color _typeColor(String type) {
    switch (type) {
      case 'Video Call':
        return const Color(0xFF3498DB);
      case 'Chat / Messaging':
        return const Color(0xFF27AE60);
      case 'Report Review Only':
        return const Color(0xFFF39C12);
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Video Call':
        return Icons.videocam_rounded;
      case 'Chat / Messaging':
        return Icons.chat_bubble_rounded;
      case 'Report Review Only':
        return Icons.description_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  IconData _catIcon(String cat) {
    const map = <String, IconData>{
      'All': Icons.grid_view_rounded,
      'Cardiology': Icons.favorite_rounded,
      'Diagnostics': Icons.biotech_rounded,
      'Lifestyle': Icons.self_improvement_rounded,
      'Pediatrics': Icons.child_care_rounded,
      'General': Icons.local_hospital_rounded,
      'Psychiatry': Icons.psychology_rounded,
      'Neurology': Icons.psychology_outlined,
      'Orthopedics': Icons.accessibility_new_rounded,
      'Dermatology': Icons.face_rounded,
      'Dentistry': Icons.medical_services_rounded,
    };
    return map[cat] ?? Icons.medical_services_rounded;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeGigProvider>().initialise();
    });
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Navigate to gig details ───────────────────────────────────────────────
  void _openGigDetails(GigModel gig) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GigDetailsProvider(),
          child: GigDetailsView(gig: gig),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeGigProvider>(
      builder: (_, prov, __) => Scaffold(
        backgroundColor: AppColors.backgroundColor,

        // ── Simple AppBar ──────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF6B35),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.8),
                  color: Colors.white.withOpacity(0.25),
                ),
                child: ClipOval(
                  child:
                      prov.patientImageUrl != null &&
                          prov.patientImageUrl!.isNotEmpty
                      ? Image.network(
                          prov.patientImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // Greeting + name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                    prov.patientLoading
                        ? Container(
                            width: 100,
                            height: 13,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          )
                        : Text(
                            prov.patientFirstName.isNotEmpty
                                ? prov.patientFirstName
                                : 'Welcome back!',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),

          // Notification bell on the right
          actions: [
            GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withOpacity(0.35)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4757),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Body ───────────────────────────────────────────────────────────
        body: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Search bar ────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchBar(prov)),

            // ── Category pills ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildCategoryPills(prov)),

            // ── Feed header ───────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildFeedHeader(prov)),

            // ── Gig feed ──────────────────────────────────────────────────
            _buildFeedSliver(prov),

            // ── Bottom padding ────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  // ── Greeting helper ────────────────────────────────────────────────────────
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 🌙';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(HomeGigProvider prov) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              onChanged: prov.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties, services…',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.55),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                prov.resetFilters();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORY PILLS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoryPills(HomeGigProvider prov) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: prov.categories.length,
          itemBuilder: (_, i) {
            final cat = prov.categories[i];
            final selected = prov.selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                prov.selectCategory(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.borderGray,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _catIcon(cat),
                      size: 13,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FEED HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFeedHeader(HomeGigProvider prov) {
    String title;
    if (prov.searchQuery.trim().isNotEmpty) {
      title = 'Results for "${prov.searchQuery.trim()}"';
    } else if (prov.selectedCategory != 'All') {
      title = prov.selectedCategory;
    } else {
      title = 'All Doctors';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (!prov.isLoading && prov.gigs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${prov.gigs.length} doctors',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FEED SLIVER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFeedSliver(HomeGigProvider prov) {
    if (prov.isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const _GigTileSkeleton(),
          childCount: 4,
        ),
      );
    }

    if (prov.hasError) {
      return SliverToBoxAdapter(
        child: _ErrorRetry(
          message: prov.errorMessage ?? 'Failed to load.',
          onRetry: prov.loadGigs,
        ),
      );
    }

    if (prov.gigs.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _GigTile(
          gig: prov.gigs[i],
          typeColor: _typeColor(prov.gigs[i].consultationTypeStr),
          typeIcon: _typeIcon(prov.gigs[i].consultationTypeStr),
          onTapCard: () => _openGigDetails(prov.gigs[i]),
          onChat: () => HapticFeedback.selectionClick(),
          onBook: () => HapticFeedback.mediumImpact(),
        ),
        childCount: prov.gigs.length,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GIG TILE
// ══════════════════════════════════════════════════════════════════════════════

class _GigTile extends StatelessWidget {
  final GigModel gig;
  final Color typeColor;
  final IconData typeIcon;
  final VoidCallback onTapCard;
  final VoidCallback onChat;
  final VoidCallback onBook;

  const _GigTile({
    required this.gig,
    required this.typeColor,
    required this.typeIcon,
    required this.onTapCard,
    required this.onChat,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: AppColors.subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorRow(),
                  const SizedBox(height: 10),
                  _buildTitle(),
                  const SizedBox(height: 5),
                  _buildMetaRow(),
                  const SizedBox(height: 10),
                  _buildTypeTags(),
                  const SizedBox(height: 12),
                  _buildPackagesRow(),
                  const SizedBox(height: 12),
                  Divider(
                      color: AppColors.borderGray, thickness: 0.8, height: 1),
                  const SizedBox(height: 12),
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (gig.coverImageUrl.isEmpty) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          Image.network(
            gig.coverImageUrl,
            height: 175,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    height: 175,
                    color: AppColors.borderGray,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          if (gig.isFeatured)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorRow() {
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gig.drName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (gig.drIsVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF3498DB),
                      size: 15,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                gig.drSpecialty,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primaryExtraLight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: gig.drImageUrl.isNotEmpty
            ? Image.network(
                gig.drImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              )
            : const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 22,
              ),
      ),
    );
  }

  Widget _buildTitle() => Text(
    gig.fullTitle,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildMetaRow() => Row(
    children: [
      if (gig.drRating > 0) ...[
        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
        const SizedBox(width: 3),
        Text(
          gig.drRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          ' (${gig.totalReviews})',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
      ],
      if (gig.totalOrders > 0) ...[
        const Icon(
          Icons.shopping_bag_outlined,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 3),
        Text(
          '${gig.totalOrders} orders',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    ],
  );

  Widget _buildTypeTags() => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      _tag(typeIcon, gig.consultationTypeStr, typeColor),
      _tag(Icons.grid_view_rounded, gig.category, AppColors.textSecondary),
      if (gig.hasPmdcUploaded)
        _tag(Icons.verified_rounded, 'PMDC Verified', const Color(0xFF27AE60)),
    ],
  );

  Widget _tag(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildPackagesRow() {
    final pkgs = [
      (
        gig.basicPackage,
        const Color(0xFF3498DB),
        const Color(0xFFEBF5FB),
        'Basic',
      ),
      (
        gig.standardPackage,
        AppColors.primary,
        AppColors.primaryExtraLight,
        'Standard',
      ),
      (
        gig.premiumPackage,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
        'Premium',
      ),
    ];
    return Row(
      children: pkgs.asMap().entries.map((e) {
        final i = e.key;
        final pkg = e.value.$1;
        final col = e.value.$2;
        final bg = e.value.$3;
        final name = e.value.$4;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: col.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: col,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${pkg.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: col,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  pkg.deliveryTime,
                  style: TextStyle(fontSize: 9, color: col.withOpacity(0.75)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() => Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Starting from',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 1),
          Text(
            'Rs. ${gig.startingPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      const Spacer(),
      GestureDetector(
        onTap: onChat,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.25)),
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onBook,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: AppColors.orangeGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Book Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SKELETON LOADER
// ══════════════════════════════════════════════════════════════════════════════

class _GigTileSkeleton extends StatefulWidget {
  const _GigTileSkeleton();
  @override
  State<_GigTileSkeleton> createState() => _GigTileSkeletonState();
}

class _GigTileSkeletonState extends State<_GigTileSkeleton>
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
    _anim = Tween<double>(
      begin: 0.4,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 175,
                decoration: BoxDecoration(
                  color: AppColors.borderGray,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _sh(44, 44, r: 12),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sh(12, 130),
                              const SizedBox(height: 6),
                              _sh(10, 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _sh(14, double.infinity),
                    const SizedBox(height: 6),
                    _sh(12, double.infinity),
                    const SizedBox(height: 6),
                    _sh(12, 180),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _sh(50, double.infinity, r: 10)),
                        const SizedBox(width: 6),
                        Expanded(child: _sh(50, double.infinity, r: 10)),
                        const SizedBox(width: 6),
                        Expanded(child: _sh(50, double.infinity, r: 10)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _sh(40, double.infinity, r: 12),
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

// ══════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ══════════════════════════════════════════════════════════════════════════════

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
    child: Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.error,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Try again',
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
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 70, horizontal: 32),
    child: Column(
      children: [
        Icon(
          Icons.search_off_rounded,
          color: AppColors.textSecondary,
          size: 52,
        ),
        SizedBox(height: 14),
        Text(
          'No doctors found',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Try a different search or category.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}