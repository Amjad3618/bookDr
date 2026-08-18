// lib/widgets/delivery_countdown.dart  ·  SAME CODE — PATIENT APP + DOCTOR APP
// ════════════════════════════════════════════════════════════════════════════
// A live-ticking countdown to an order's delivery deadline. Both apps show
// the exact same countdown because both read the same `deliveryDeadline`
// timestamp stored on the order (set once in OrderService.markPaid) — no
// direct communication between the two apps is needed, Firestore is the
// single source of truth they both read from.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';

class DeliveryCountdown extends StatefulWidget {
  final DateTime? deadline;
  const DeliveryCountdown({super.key, required this.deadline});

  @override
  State<DeliveryCountdown> createState() => _DeliveryCountdownState();
}

class _DeliveryCountdownState extends State<DeliveryCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (widget.deadline == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final diff = widget.deadline!.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d == Duration.zero) return '00:00:00';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (days > 0) return '${days}d $hh:$mm:$ss';
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deadline == null) return const SizedBox.shrink();

    final overdue = _remaining == Duration.zero;
    final color = overdue ? Colors.red : Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            overdue ? Icons.warning_amber_rounded : Icons.timer_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            overdue ? 'Delivery overdue' : _format(_remaining),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}