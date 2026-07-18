// lib/views/booking/booking_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// Fiverr-style booking flow, opened from a gig's package "Book Now" button.
//
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => ChangeNotifierProvider(
//       create: (_) => BookingProvider(),
//       child: BookingView(
//         gig: gig,
//         packageType: 'standard',       // 'basic' | 'standard' | 'premium'
//       ),
//     ),
//   ));
//
// 3 steps: Requirements → Review & Pay → Confirmation.
// Payment is currently a PLACEHOLDER (see BookingProvider.confirmPayment) —
// swap that one method for the real Stripe flow later; this screen and
// OrderService don't need to change.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/dr_model.dart';   // GigModel — adjust import to your project
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class BookingView extends StatefulWidget {
  final GigModel gig;
  final String   packageType; // 'basic' | 'standard' | 'premium'

  const BookingView({
    super.key,
    required this.gig,
    required this.packageType,
  });

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  int _step = 0; // 0 = requirements, 1 = review & pay, 2 = confirmation
  final _reqCtrl = TextEditingController();

  _PkgInfo get _pkg {
    switch (widget.packageType) {
      case 'premium':
        return _PkgInfo(
          name: widget.gig.premiumPackage.name,
          price: widget.gig.premiumPackage.price,
          delivery: widget.gig.premiumPackage.deliveryTime,
          features: widget.gig.premiumPackage.features,
        );
      case 'standard':
        return _PkgInfo(
          name: widget.gig.standardPackage.name,
          price: widget.gig.standardPackage.price,
          delivery: widget.gig.standardPackage.deliveryTime,
          features: widget.gig.standardPackage.features,
        );
      case 'basic':
      default:
        return _PkgInfo(
          name: widget.gig.basicPackage.name,
          price: widget.gig.basicPackage.price,
          delivery: widget.gig.basicPackage.deliveryTime,
          features: widget.gig.basicPackage.features,
        );
    }
  }

  @override
  void dispose() {
    _reqCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequirements(BookingProvider prov) async {
    if (_reqCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in the requirements before continuing.'),
      ));
      return;
    }

    final patient = context.read<PatientAuthProvider>().patient;
    if (patient == null) return;

    final pkg = _pkg;
    final ok = await prov.createOrder(
      patientId:       patient.patientId,
      patientName:     patient.name,
      patientImageUrl: patient.profileImageUrl ?? '',
      doctorId:        widget.gig.drId,
      doctorName:      widget.gig.drName,
      doctorImageUrl:  widget.gig.drImageUrl,
      gigId:           widget.gig.gigId,
      gigTitle:        widget.gig.title,
      packageType:     widget.packageType,
      packageName:     pkg.name,
      packagePrice:    pkg.price,
      packageDeliveryTime: pkg.delivery,
      packageFeatures: pkg.features,
      requirements:    _reqCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      HapticFeedback.selectionClick();
      setState(() => _step = 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.errorMessage ?? 'Something went wrong.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _pay(BookingProvider prov) async {
    final ok = await prov.confirmPayment();
    if (!mounted) return;
    if (ok) {
      HapticFeedback.mediumImpact();
      setState(() => _step = 2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(prov.errorMessage ?? 'Payment failed.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (_, prov, __) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: IndexedStack(
                index: _step,
                children: [
                  _buildRequirementsStep(prov),
                  _buildReviewPayStep(prov),
                  _buildConfirmationStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: const Color(0xFFFF6B35),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: Colors.white, size: 18),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text('Book Appointment',
        style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // STEPPER HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStepper() {
    const labels = ['Requirements', 'Review & Pay', 'Confirmed'];
    return Container(
      color: const Color(0xFFFF6B35),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: List.generate(labels.length, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? const Color(0xFF2ECC71)
                      : active ? Colors.white : Colors.white.withOpacity(0.25),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text('${i + 1}', style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          color: active ? const Color(0xFFFF6B35) : Colors.white70)),
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[i], style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: active || done ? Colors.white : Colors.white70)),
              if (i < labels.length - 1)
                Expanded(child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 2,
                  color: done ? const Color(0xFF2ECC71) : Colors.white.withOpacity(0.25),
                )),
            ]),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — REQUIREMENTS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRequirementsStep(BookingProvider prov) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _packageSummaryCard(),
          const SizedBox(height: 20),
          const Text('Before we start',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            widget.gig.requirements.isNotEmpty
                ? widget.gig.requirements
                : 'Please describe your symptoms and any relevant history.',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: TextField(
              controller: _reqCtrl,
              maxLines: 7,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Type your answer here…',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label: 'Continue',
            busy: prov.isSubmitting,
            onTap: () => _submitRequirements(prov),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — REVIEW & PAY
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildReviewPayStep(BookingProvider prov) {
    final pkg = _pkg;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _packageSummaryCard(),
          const SizedBox(height: 20),
          const Text('Order Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(children: [
              _summaryRow('Package', pkg.name),
              const SizedBox(height: 10),
              _summaryRow('Delivery', pkg.delivery),
              const SizedBox(height: 10),
              const Divider(color: AppColors.borderGray),
              const SizedBox(height: 4),
              _summaryRow('Total',
                  'Rs. ${pkg.price.toStringAsFixed(0)}', bold: true),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Payment Method',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.4),
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.credit_card_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Stripe',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary))),
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            ]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Note: payment is running in test mode right now — no real charge '
            'will be made.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            label: prov.isPaying
                ? 'Processing payment…'
                : 'Pay Rs. ${pkg.price.toStringAsFixed(0)}',
            busy: prov.isPaying,
            onTap: () => _pay(prov),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — CONFIRMATION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildConfirmationStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(
                color: AppColors.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 50),
            ),
            const SizedBox(height: 22),
            const Text('Booking Confirmed!',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Dr. ${widget.gig.drName} will review your requirements and '
              'reach out to schedule your video consultation.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('View My Appointments',
                      style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _packageSummaryCard() {
    final pkg = _pkg;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.gig.drImageUrl.isNotEmpty
              ? Image.network(widget.gig.drImageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded, color: AppColors.primary))
              : const Icon(Icons.person_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Dr. ${widget.gig.drName}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(widget.gig.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('${pkg.name} · Rs. ${pkg.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ]),
        ),
      ]),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      Text(value, style: TextStyle(
          fontSize: bold ? 15 : 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          color: bold ? AppColors.primary : AppColors.textPrimary)),
    ],
  );

  Widget _primaryButton({
    required String label,
    required bool busy,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: busy ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: busy ? null : AppColors.orangeGradient,
        color: busy ? AppColors.borderGray : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: busy
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Text(label, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// LOCAL HELPER
// ══════════════════════════════════════════════════════════════════════════════

class _PkgInfo {
  final String name;
  final double price;
  final String delivery;
  final List<String> features;
  const _PkgInfo({
    required this.name,
    required this.price,
    required this.delivery,
    required this.features,
  });
}