

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
  final _scrollCtrl   = ScrollController();
  final _pageCtrl     = PageController();
  bool  _showSticky   = false;
  bool  _isFavorited  = false;
  int   _galleryPage  = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollCtrl.offset > 230;
    if (show != _showSticky) setState(() => _showSticky = show);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  List<String> _allImages(GigModel gig) {
    final imgs = <String>[];
    if (gig.coverImageUrl.isNotEmpty) imgs.add(gig.coverImageUrl);
    for (final url in gig.galleryImageUrls) {
      if (url.isNotEmpty && !imgs.contains(url)) imgs.add(url);
    }
    return imgs;
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Video Call':         return const Color(0xFF2563EB);
      case 'Chat / Messaging':   return const Color(0xFF059669);
      case 'Report Review Only': return const Color(0xFFD97706);
      default:                   return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Video Call':         return Icons.videocam_rounded;
      case 'Chat / Messaging':   return Icons.chat_bubble_rounded;
      case 'Report Review Only': return Icons.description_rounded;
      default:                   return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            ListView(
              controller: _scrollCtrl,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _buildImageGallery(widget.gig),
                _buildDoctorCard(widget.gig),
                _buildTitleSection(widget.gig),
                _buildDescriptionSection(widget.gig),
                _buildPackagesSection(widget.gig),
                if (widget.gig.requirements.trim().isNotEmpty)
                  _buildRequirementsSection(widget.gig),
                if (widget.gig.faqs.isNotEmpty) _buildFaqSection(widget.gig),
                _buildStatsSection(widget.gig),
                const SizedBox(height: 110),
              ],
            ),
            Positioned(
              top: topPad + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _overlayBtn(Icons.arrow_back_ios_new_rounded,
                      () => Navigator.pop(context)),
                  const Spacer(),
                  _overlayBtn(
                    _isFavorited
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    () {
                      HapticFeedback.lightImpact();
                      setState(() => _isFavorited = !_isFavorited);
                    },
                    color: _isFavorited ? Colors.red : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  _overlayBtn(Icons.share_outlined,
                      () => HapticFeedback.lightImpact()),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _showSticky ? 0 : -80,
              left: 0,
              right: 0,
              child: _buildStickyHeader(widget.gig),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, widget.gig),
      ),
    );
  }

  // ── Image gallery ───────────────────────────────────────────────────────
  Widget _buildImageGallery(GigModel gig) {
    final images = _allImages(gig);

    assert(() {
      debugPrint('GigDetailsView -> images found: ${images.length} -> $images');
      return true;
    }());

    if (images.isEmpty) {
      return SizedBox(height: 280, child: _coverPlaceholder());
    }

    return SizedBox(
      height: images.length > 1 ? 340 : 280,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageCtrl,
                  physics: const PageScrollPhysics(),
                  allowImplicitScrolling: false,
                  itemCount: images.length,
                  onPageChanged: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _galleryPage = i);
                  },
                  itemBuilder: (_, i) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openImageViewer(images, i),
                    child: Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    ),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x55000000),
                        Colors.transparent,
                        Color(0x88000000),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => GestureDetector(
                          onTap: () => _pageCtrl.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _galleryPage == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _galleryPage == i
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (images.length > 1)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_galleryPage + 1} / ${images.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (gig.isFeatured)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Thumbnail strip — explicit, tap-to-jump navigation so the
          // gallery never depends solely on swipe gestures working.
          if (images.length > 1)
            Container(
              height: 60,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _galleryPage == i;
                  return GestureDetector(
                    onTap: () => _pageCtrl.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderGray,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          images[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primaryExtraLight,
                            child: const Icon(Icons.image_rounded,
                                size: 16, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: const Center(
          child: Icon(Icons.medical_services_rounded,
              color: Colors.white54, size: 72),
        ),
      );

  Widget _overlayBtn(IconData icon, VoidCallback onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
            border:
                Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Icon(icon, color: color ?? Colors.white, size: 18),
        ),
      );

  Widget _buildStickyHeader(GigModel gig) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              gig.fullTitle,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.orangeGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Rs. ${gig.basicPackage.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(GigModel gig) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primaryExtraLight,
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: gig.drImageUrl.isNotEmpty
                      ? Image.network(gig.drImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 30))
                      : const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 30),
                ),
              ),
              if (gig.drIsVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gig.drName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(gig.drSpecialty,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                if (gig.drRating > 0)
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < gig.drRating.floor()
                              ? Icons.star_rounded
                              : (i < gig.drRating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded),
                          size: 13,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${gig.drRating.toStringAsFixed(1)} (${gig.totalReviews})',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              child: const Text('View Profile',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(GigModel gig) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gig.fullTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _tag(_typeIcon(gig.consultationTypeStr),
                  gig.consultationTypeStr,
                  _typeColor(gig.consultationTypeStr)),
              _tag(Icons.grid_view_rounded, gig.category,
                  AppColors.textSecondary),
              if (gig.subcategory.isNotEmpty)
                _tag(Icons.label_outline_rounded, gig.subcategory,
                    AppColors.textSecondary),
              if (gig.hasPmdcUploaded)
                _tag(Icons.verified_rounded, 'PMDC Verified',
                    const Color(0xFF059669)),
              if (gig.hasDegreeUploaded)
                _tag(Icons.school_rounded, 'Degree Verified',
                    const Color(0xFF7C3AED)),
            ],
          ),
          if (gig.totalOrders > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderGray),
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(Icons.shopping_bag_outlined,
                    '${gig.totalOrders} orders', AppColors.primary),
                const SizedBox(width: 10),
                _statChip(Icons.visibility_outlined,
                    '${gig.totalViews} views', AppColors.textSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );

  Widget _statChip(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      );

  void _openImageViewer(List<String> images, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            _ImageViewer(images: images, initialIndex: index),
      ),
    );
  }

  Widget _buildDescriptionSection(GigModel gig) => _sectionCard(
        icon: Icons.description_outlined,
        title: 'About This Service',
        child: Text(
          gig.description,
          style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.7),
        ),
      );

  Widget _buildPackagesSection(GigModel gig) {
    final pkgNames  = ['Basic', 'Standard', 'Premium'];
    final pkgColors = [
      const Color(0xFF2563EB),
      AppColors.primary,
      const Color(0xFFD97706),
    ];
    final pkgBgs = [
      const Color(0xFFEFF6FF),
      AppColors.primaryExtraLight,
      const Color(0xFFFEF3C7),
    ];
    final pkgs = [gig.basicPackage, gig.standardPackage, gig.premiumPackage];

    return _sectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Choose a Package',
      child: Consumer<GigDetailsProvider>(
        builder: (_, prov, __) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: List.generate(3, (i) {
                  final sel = prov.selectedPackageIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        prov.selectPackage(i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? pkgColors[i] : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: pkgColors[i].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              pkgNames[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: sel
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rs. ${pkgs[i].price.toStringAsFixed(0)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _buildPackageDetail(
                pkgs[prov.selectedPackageIndex],
                pkgColors[prov.selectedPackageIndex],
                pkgBgs[prov.selectedPackageIndex],
                key: ValueKey(prov.selectedPackageIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetail(GigPackage pkg, Color color, Color bg,
      {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pkg.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    if (pkg.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(pkg.description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Rs. ${pkg.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(child: _pkgMeta(Icons.access_time_rounded,
                    pkg.deliveryTime, color)),
                Container(
                    width: 1, height: 24, color: color.withOpacity(0.2)),
                Expanded(child: _pkgMeta(Icons.refresh_rounded,
                    pkg.revisions, color)),
              ],
            ),
          ),
          if (pkg.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...pkg.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 1),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 11, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.4)),
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

  Widget _pkgMeta(IconData icon, String label, Color color) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  Widget _buildRequirementsSection(GigModel gig) => _sectionCard(
        icon: Icons.checklist_rounded,
        title: 'What You Need to Provide',
        child: Text(gig.requirements,
            style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.7)),
      );

  Widget _buildFaqSection(GigModel gig) => _sectionCard(
        icon: Icons.help_outline_rounded,
        title: 'Frequently Asked Questions',
        child: Column(
          children: gig.faqs
              .asMap()
              .entries
              .map((e) => _FaqTile(index: e.key, faq: e.value))
              .toList(),
        ),
      );

  Widget _buildStatsSection(GigModel gig) => _sectionCard(
        icon: Icons.bar_chart_rounded,
        title: 'Service Stats',
        child: Row(
          children: [
            Expanded(
                child: _statCard(Icons.shopping_bag_outlined,
                    '${gig.totalOrders}', 'Orders', AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(
                child: _statCard(Icons.star_rounded,
                    gig.rating.toStringAsFixed(1), 'Rating',
                    const Color(0xFFF59E0B))),
            const SizedBox(width: 10),
            Expanded(
                child: _statCard(Icons.visibility_outlined,
                    '${gig.totalViews}', 'Views',
                    const Color(0xFF7C3AED))),
          ],
        ),
      );

  Widget _statCard(IconData icon, String value, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: AppColors.subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.orangeGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );

  Widget _buildBottomBar(BuildContext context, GigModel gig) {
    return Consumer<GigDetailsProvider>(
      builder: (_, prov, __) {
        final pkg = prov.selectedPackage ?? gig.basicPackage;
        final pkgName =
            ['Basic', 'Standard', 'Premium'][prov.selectedPackageIndex];
        return Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderGray)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkgName,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                  Text(
                    'Rs. ${pkg.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => HapticFeedback.mediumImpact(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Book Now',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const _ImageViewer({required this.images, required this.initialIndex});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late int _current;
  late PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: PageView.builder(
              controller: _ctrl,
              physics: const PageScrollPhysics(),
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.images[i],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white54,
                        size: 60),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Text(
                '${_current + 1} / ${widget.images.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.primaryExtraLight
              : AppColors.lightGray,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.borderGray,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _expanded
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('Q',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _expanded
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _expanded
                              ? AppColors.primary
                              : AppColors.textPrimary),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _expanded
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('A',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(widget.faq.answer,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.6)),
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}