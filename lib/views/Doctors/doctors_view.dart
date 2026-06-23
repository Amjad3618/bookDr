// lib/views/Doctors/doctors_view.dart  ·  PATIENT APP
//
// Fetches real doctors from the 'doctors' Firestore collection
// via DoctorProvider → DoctorService.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bookdr/core/theme/app_colors.dart';

import '../../models/fetch_de_model.dart';
import '../../providers/fetch_dr_provider.dart';

class DoctorsView extends StatefulWidget {
  const DoctorsView({super.key});

  @override
  State<DoctorsView> createState() => _DoctorsViewState();
}

class _DoctorsViewState extends State<DoctorsView> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().initialise();
    });
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorProvider>(
      builder: (_, prov, __) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF6B35),
          elevation: 0,
          title: const Text(
            'Find a Doctor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(prov),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: prov.refresh,
                  child: _buildBody(prov),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(DoctorProvider prov) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      height: 48,
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
                hintText: 'Search doctors, specialties…',
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
  // BODY — handles loading / error / empty / list
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBody(DoctorProvider prov) {
    if (prov.isLoading && prov.doctors.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const _DoctorCardSkeleton(),
      );
    }

    if (prov.hasError) {
      return _ErrorRetry(
        message: prov.errorMessage ?? 'Failed to load doctors.',
        onRetry: prov.loadDoctors,
      );
    }

    if (prov.doctors.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      itemCount: prov.doctors.length,
      itemBuilder: (context, index) => _DoctorCard(doctor: prov.doctors[index]),
    );
  }
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          // Doctor image + online dot
          Stack(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primaryExtraLight,
                  image:
                      doctor.profileImageUrl != null &&
                          doctor.profileImageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(doctor.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    doctor.profileImageUrl == null ||
                        doctor.profileImageUrl!.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 34,
                      )
                    : null,
              ),
              if (doctor.isOnline)
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Doctor info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (doctor.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF3498DB),
                        size: 15,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  doctor.subSpecialty.isNotEmpty
                      ? '${doctor.specialty} · ${doctor.subSpecialty}'
                      : doctor.specialty,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.yearsOfExperience} yrs',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      doctor.rating > 0
                          ? doctor.rating.toStringAsFixed(1)
                          : 'New',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Book button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              // TODO: navigate to doctor profile / booking using doctor.drId
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
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
              child: const Text(
                'Book',
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SKELETON LOADER
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
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              _sh(76, 76, r: 14),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sh(14, 140),
                    const SizedBox(height: 8),
                    _sh(11, 100),
                    const SizedBox(height: 10),
                    _sh(11, 80),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _sh(38, 64, r: 12),
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
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    children: [
      Padding(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
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
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),
    children: const [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 70, horizontal: 32),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
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
              'Try a different search or check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
