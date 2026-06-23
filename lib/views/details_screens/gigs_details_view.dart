// lib/views/gig_details_view.dart  ·  PATIENT APP
//
// Shown when a patient taps a gig card on the home feed.
// Receives the GigModel directly (no extra fetch needed) via
// GigDetailsProvider.setGig(), keeping navigation instant.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bookdr/core/theme/app_colors.dart';

import '../../models/dr_model.dart';
import '../../providers/gig_details_provider.dart';

class GigDetailsView extends StatefulWidget {
  final GigModel gig;
  const GigDetailsView({super.key, required this.gig});

  @override
  State<GigDetailsView> createState() => _GigDetailsViewState();
}

class _GigDetailsViewState extends State<GigDetailsView> {
  final _scrollCtrl = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GigDetailsProvider>().setGig(widget.gig);
    });
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 220;
      if (show != _showStickyHeader) {
        setState(() => _showStickyHeader = show);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    // Clear so the next gig opened starts fresh
    context.read<GigDetailsProvider>().clear();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Consumer<GigDetailsProvider>(
      builder: (_, prov, __) {
        final gig = prov.gig;

        if (gig == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildCoverSliverAppBar(gig),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildDoctorCard(gig),
                        _buildTitleSection(gig),
                        _buildDescriptionSection(gig),
                        _buildPackagesSection(gig, prov),
                        _buildRequirementsSection(gig),
                        if (gig.faqs.isNotEmpty) _buildFaqSection(gig),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Sticky mini header, fades in on scroll ───────────────────
              if (_showStickyHeader) _buildStickyHeader(gig),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, gig, prov),
        );
      },
    );
  }

  // ── Cover image + collapsing app bar ──────────────────────────────────────
  Widget _buildCoverSliverAppBar(GigModel gig) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: _circleBtn(
        Icons.arrow_back_ios_new_rounded,
        () => Navigator.pop(context),
      ),
      actions: [
        _circleBtn(Icons.favorite_border_rounded, () {
          HapticFeedback.lightImpact();
        }),
        _circleBtn(Icons.share_outlined, () {}),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: gig.coverImageUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    gig.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryExtraLight,
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 60,
                      ),
                    ),
                  ),
                  // Gradient overlay so the back/share buttons stay visible
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.all(4),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    ),
  );

  // ── Sticky header that fades in once user scrolls past cover ─────────────
  Widget _buildStickyHeader(GigModel gig) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showStickyHeader ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(
            8,
            MediaQuery.of(context).padding.top + 4,
            16,
            12,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  gig.fullTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Doctor card ────────────────────────────────────────────────────────────
  Widget _buildDoctorCard(GigModel gig) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primaryExtraLight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: gig.drImageUrl.isNotEmpty
                  ? Image.network(
                      gig.drImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        gig.drName,
                        style: const TextStyle(
                          fontSize: 14,
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
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (gig.drRating > 0) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Color(0xFFF59E0B),
                      ),
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
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // TODO: navigate to doctor profile screen with gig.drId
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title + tags ───────────────────────────────────────────────────────────
  Widget _buildTitleSection(GigModel gig) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gig.fullTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag(
                _typeIcon(gig.consultationTypeStr),
                gig.consultationTypeStr,
                _typeColor(gig.consultationTypeStr),
              ),
              _tag(
                Icons.grid_view_rounded,
                gig.category,
                AppColors.textSecondary,
              ),
              if (gig.subcategory.isNotEmpty)
                _tag(
                  Icons.label_outline_rounded,
                  gig.subcategory,
                  AppColors.textSecondary,
                ),
              if (gig.hasPmdcUploaded)
                _tag(
                  Icons.verified_rounded,
                  'PMDC Verified',
                  const Color(0xFF27AE60),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (gig.totalOrders > 0) ...[
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gig.totalOrders} orders completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );

  // ── Description ────────────────────────────────────────────────────────────
  Widget _buildDescriptionSection(GigModel gig) {
    return _sectionCard(
      icon: Icons.description_outlined,
      title: 'About This Service',
      child: Text(
        gig.description,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  // ── Packages (Basic / Standard / Premium tabs) ────────────────────────────
  Widget _buildPackagesSection(GigModel gig, GigDetailsProvider prov) {
    final pkgNames = ['Basic', 'Standard', 'Premium'];
    final pkgColors = [
      const Color(0xFF3498DB),
      AppColors.primary,
      const Color(0xFFF59E0B),
    ];
    final pkgBgs = [
      const Color(0xFFEBF5FB),
      AppColors.primaryExtraLight,
      const Color(0xFFFEF3C7),
    ];
    final pkgs = [gig.basicPackage, gig.standardPackage, gig.premiumPackage];

    return _sectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Choose a Package',
      child: Column(
        children: [
          // Tab selector
          Row(
            children: List.generate(3, (i) {
              final sel = prov.selectedPackageIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    prov.selectPackage(i);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? pkgColors[i] : pkgBgs[i],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? pkgColors[i]
                            : pkgColors[i].withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      pkgNames[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: sel ? Colors.white : pkgColors[i],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Selected package details
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildPackageDetail(
              pkgs[prov.selectedPackageIndex],
              pkgColors[prov.selectedPackageIndex],
              pkgBgs[prov.selectedPackageIndex],
              key: ValueKey(prov.selectedPackageIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(
    GigPackage pkg,
    Color color,
    Color bg, {
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pkg.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Text(
                'Rs. ${pkg.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (pkg.description.isNotEmpty)
            Text(
              pkg.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                pkg.deliveryTime,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.refresh_rounded, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                pkg.revisions,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          if (pkg.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white54, height: 1),
            const SizedBox(height: 12),
            ...pkg.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 15, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Requirements ────────────────────────────────────────────────────────────
  Widget _buildRequirementsSection(GigModel gig) {
    if (gig.requirements.trim().isEmpty) return const SizedBox.shrink();
    return _sectionCard(
      icon: Icons.checklist_rounded,
      title: 'What You Need to Provide',
      child: Text(
        gig.requirements,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.7,
        ),
      ),
    );
  }

  // ── FAQ ──────────────────────────────────────────────────────────────────────
  Widget _buildFaqSection(GigModel gig) {
    return _sectionCard(
      icon: Icons.help_outline_rounded,
      title: 'Frequently Asked Questions',
      child: Column(
        children: gig.faqs.asMap().entries.map((e) {
          return _FaqTile(index: e.key, faq: e.value);
        }).toList(),
      ),
    );
  }

  // ── Shared section card wrapper ─────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) => Container(
    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: AppColors.subtleShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  // ── Bottom bar — price + chat + book ──────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    GigModel gig,
    GigDetailsProvider prov,
  ) {
    final pkg = prov.selectedPackage ?? gig.basicPackage;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selected price',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              Text(
                'Rs. ${pkg.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // TODO: navigate to chat with gig.drId
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // TODO: navigate to booking screen with gig + selected package
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FAQ TILE — expandable
// ══════════════════════════════════════════════════════════════════════════════

class _FaqTile extends StatefulWidget {
  final int index;
  final GigFaq faq;
  const _FaqTile({required this.index, required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.faq.answer,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
