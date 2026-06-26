// lib/features/profile/views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/patient_model.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientAuthProvider>(
      builder: (context, authProvider, _) {
final PatientModel? patient = authProvider.patient;
        if (patient == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return _ProfileContent(patient: patient);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Content
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _buildHeader(context),

              // ── Profile Hero Card ────────────────────────────────────────
              _ProfileHeroCard(patient: patient),

              const SizedBox(height: 24),

              // ── Wallet Stats Row ─────────────────────────────────────────
              _WalletStatsRow(patient: patient),

              const SizedBox(height: 24),

              // ── Personal Information ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Personal Information'),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.cake_rounded,
                      title: 'Date of Birth',
                      value: _formatDob(patient.dateOfBirth),
                    ),
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.wc_rounded,
                      title: 'Gender',
                      value: patient.gender ?? 'Not set',
                    ),
                    const SizedBox(height: 10),
                    _InfoCard(
                      icon: Icons.bloodtype_rounded,
                      title: 'Blood Group',
                      value: patient.bloodGroup ?? 'Not set',
                    ),
                    if (patient.city != null || patient.address != null) ...[
                      const SizedBox(height: 10),
                      _InfoCard(
                        icon: Icons.location_on_rounded,
                        title: 'Location',
                        value: [patient.city, patient.address]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', '),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Medical History ──────────────────────────────────────────
              if (patient.medicalHistory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Medical History'),
                      const SizedBox(height: 12),
                      _TagsCard(
                        icon: Icons.medical_information_rounded,
                        tags: patient.medicalHistory,
                        color: AppColors.errorLight,
                        tagColor: AppColors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Allergies ────────────────────────────────────────────────
              if (patient.allergies.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Allergies'),
                      const SizedBox(height: 12),
                      _TagsCard(
                        icon: Icons.warning_amber_rounded,
                        tags: patient.allergies,
                        color: AppColors.warningLight,
                        tagColor: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Account Status ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Account'),
                    const SizedBox(height: 12),
                    _AccountStatusCard(patient: patient),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: navigate to EditProfileView
                        },
                        style: AppColors.primaryButtonStyle,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: navigate to AppointmentsView
                        },
                        style: AppColors.secondaryButtonStyle,
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: const Text(
                          'View Appointments',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: navigate to SettingsView
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppColors.subtleShadow,
              ),
              child: const Icon(
                Icons.settings_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _formatDob(String? dob) {
    if (dob == null || dob.isEmpty) return 'Not set';
    try {
      final dt = DateTime.parse(dob);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dob;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Hero Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.orangeGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -10,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: patient.profileImageUrl != null &&
                                  patient.profileImageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: patient.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => _avatarFallback(),
                                  errorWidget: (_, __, ___) => _avatarFallback(),
                                )
                              : _avatarFallback(),
                        ),
                      ),
                      // Camera badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    patient.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Phone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        patient.phone.isNotEmpty ? patient.phone : 'No phone',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Verified badge
                  if (patient.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: AppColors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Verified Account',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.primaryExtraLight,
      alignment: Alignment.center,
      child: Text(
        patient.initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wallet Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _WalletStatsRow extends StatelessWidget {
  const _WalletStatsRow({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Wallet Balance',
              value: '\$${patient.walletBalance.toStringAsFixed(2)}',
              iconColor: AppColors.success,
              bgColor: AppColors.successLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long_rounded,
              label: 'Total Spent',
              value: '\$${patient.totalSpent.toStringAsFixed(2)}',
              iconColor: AppColors.primary,
              bgColor: AppColors.primaryExtraLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tags Card (Medical History / Allergies)
// ─────────────────────────────────────────────────────────────────────────────

class _TagsCard extends StatelessWidget {
  const _TagsCard({
    required this.icon,
    required this.tags,
    required this.color,
    required this.tagColor,
  });

  final IconData icon;
  final List<String> tags;
  final Color color;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: tagColor),
                const SizedBox(width: 5),
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account Status Card
// ─────────────────────────────────────────────────────────────────────────────

class _AccountStatusCard extends StatelessWidget {
  const _AccountStatusCard({required this.patient});

  final PatientModel patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        children: [
          _StatusRow(
            label: 'Account Status',
            isActive: patient.isActive,
            activeText: 'Active',
            inactiveText: 'Inactive',
          ),
          const Divider(height: 20, color: AppColors.borderGray),
          _StatusRow(
            label: 'Verification',
            isActive: patient.isVerified,
            activeText: 'Verified',
            inactiveText: 'Unverified',
          ),
          const Divider(height: 20, color: AppColors.borderGray),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Member Since',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDate(patient.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
  });

  final String label;
  final bool isActive;
  final String activeText;
  final String inactiveText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.successLight : AppColors.errorLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isActive ? activeText : inactiveText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}