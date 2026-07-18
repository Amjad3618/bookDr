// lib/views/appointments/appointments_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// "My Appointments" — now backed by REAL orders from Firestore (the same
// 'orders' collection the booking flow writes to), instead of dummy data.
// A booking shows up here the instant it's created, and updates live as
// its status changes.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';

class AppointmentsView extends StatefulWidget {
  const AppointmentsView({super.key});

  @override
  State<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<AppointmentsView> {
  String selectedTab = 'Upcoming';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patient = context.read<PatientAuthProvider>().patient;
      if (patient != null) {
        context.read<AppointmentsProvider>().startListening(patient.patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<AppointmentsProvider>(
          builder: (_, prov, __) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Appointments',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your medical consultations',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTabButton('Upcoming', 'Upcoming', prov.upcoming.length),
                      const SizedBox(width: 12),
                      _buildTabButton('Completed', 'Completed', prov.completed.length),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildBody(prov)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBody(AppointmentsProvider prov) {
    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (prov.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.grey[400], size: 48),
              const SizedBox(height: 12),
              Text(prov.errorMessage!, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final patient = context.read<PatientAuthProvider>().patient;
                  if (patient != null) prov.startListening(patient.patientId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Try again', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final list = selectedTab == 'Upcoming' ? prov.upcoming : prov.completed;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84, height: 84,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedTab == 'Upcoming'
                      ? Icons.calendar_today_outlined
                      : Icons.check_circle_outline_rounded,
                  color: Colors.teal, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                selectedTab == 'Upcoming'
                    ? 'No upcoming appointments'
                    : 'No completed appointments yet',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                selectedTab == 'Upcoming'
                    ? 'Book a doctor from the Home tab to see it here.'
                    : 'Appointments will move here once completed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildAppointmentCard(list[i], context),
      ),
    );
  }

  Widget _buildTabButton(String label, String value, int count) {
    bool isActive = selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.25) : Colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$count', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.teal)),
            ),
          ],
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APPOINTMENT CARD  (built from a real OrderModel)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAppointmentCard(OrderModel order, BuildContext context) {
    final statusColor = _statusColor(order.status);
    final statusLabel = _statusLabel(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.teal.withOpacity(0.08),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: order.doctorImageUrl.isNotEmpty
                      ? Image.network(order.doctorImageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded, color: Colors.teal, size: 30))
                      : const Icon(Icons.person_rounded, color: Colors.teal, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${order.doctorName}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(order.gigTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.teal, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusLabel,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(context,
                    icon: Icons.inventory_2_rounded,
                    label: 'Package',
                    value: '${order.packageName} · Rs. ${order.packagePrice.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                _buildDetailRow(context,
                    icon: Icons.event_available_rounded,
                    label: 'Booked on',
                    value: order.createdAt != null
                        ? _formatDate(order.createdAt!)
                        : '—'),
                if (order.requirements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(context,
                      icon: Icons.notes_rounded,
                      label: 'Your notes',
                      value: order.requirements),
                ],
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildActions(order, context),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(OrderModel order, BuildContext context) {
    if (order.status == OrderStatus.active || order.status == OrderStatus.delivered) {
      return Row(children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showOrderDetails(context, order),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.teal, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('View Details',
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Video calling isn't wired up yet — ZegoCloud integration
              // is the next step. This is intentionally a placeholder so
              // the button doesn't silently do nothing.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Video calling is coming soon for this appointment.'),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 4,
            ),
            child: const Text('Join Call',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ]);
    }

    if (order.status == OrderStatus.pendingPayment) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _showOrderDetails(context, order),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.orange, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Complete Payment',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
        ),
      );
    }

    // Completed or cancelled
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _showOrderDetails(context, order),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('View Details',
            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${order.doctorName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(order.gigTitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            _detailLine('Package', order.packageName),
            _detailLine('Price', 'Rs. ${order.packagePrice.toStringAsFixed(0)}'),
            _detailLine('Delivery', order.packageDeliveryTime),
            _detailLine('Status', _statusLabel(order.status)),
            _detailLine('Payment', order.isPaid ? 'Paid' : 'Pending'),
            if (order.transactionRef != null)
              _detailLine('Transaction Ref', order.transactionRef!),
            if (order.requirements.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Your notes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(order.requirements, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.5)),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingPayment: return Colors.orange;
      case OrderStatus.active:         return Colors.green;
      case OrderStatus.delivered:      return Colors.blue;
      case OrderStatus.completed:      return Colors.blue;
      case OrderStatus.cancelled:      return Colors.grey;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pendingPayment: return 'Pending Payment';
      case OrderStatus.active:         return 'Confirmed';
      case OrderStatus.delivered:      return 'Delivered';
      case OrderStatus.completed:      return 'Completed';
      case OrderStatus.cancelled:      return 'Cancelled';
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}