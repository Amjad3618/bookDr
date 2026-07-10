// lib/views/dm_view/dm_list_view.dart  ·  PATIENT APP
// ════════════════════════════════════════════════════════════════════════════
// "Messages" tab screen — put this directly in your bottom nav's _screens
// list in place of DmView. Shows every doctor conversation the patient has,
// WhatsApp-style. First-time users see "No chats yet". Tapping a tile opens
// the actual chat room (DmView) for that doctor.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/dm_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dm_list_provider.dart';
import 'dm_view.dart';

class DmListView extends StatefulWidget {
  const DmListView({super.key});

  @override
  State<DmListView> createState() => _DmListViewState();
}

class _DmListViewState extends State<DmListView> {
  late final DmListProvider _prov;

  @override
  void initState() {
    super.initState();
    _prov = DmListProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patient = context.read<PatientAuthProvider>().patient;
      if (patient != null) _prov.initialise(patient.patientId);
    });
  }

  @override
  void dispose() {
    _prov.dispose();
    super.dispose();
  }

  void _openChatFor(DmConversation conv) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DmView(
          doctorId:       conv.doctorId,
          doctorName:     conv.doctorName,
          doctorImageUrl: conv.doctorImageUrl,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DmListProvider>.value(
      value: _prov,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF6B35),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Chats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<DmListProvider>(
          builder: (_, prov, __) {
            if (prov.isLoading) return _buildLoading();

            if (prov.errorMessage != null) {
              return _buildError(prov.errorMessage!, () {
                final patient = context.read<PatientAuthProvider>().patient;
                if (patient != null) prov.initialise(patient.patientId);
              });
            }

            if (prov.isEmpty) return _buildEmptyState();

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: prov.conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 78,
                color: AppColors.borderGray.withOpacity(0.6),
              ),
              itemBuilder: (_, i) {
                final conv = prov.conversations[i];
                return _ConversationTile(
                  conv:  conv,
                  onTap: () => _openChatFor(conv),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE — first time, no chats yet
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No chats yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When you message a doctor, your conversation will show up here.',
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                decoration: BoxDecoration(
                  gradient: AppColors.orangeGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOADING SKELETON
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const _ConversationTileSkeleton(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONVERSATION TILE
// ══════════════════════════════════════════════════════════════════════════════

class _ConversationTile extends StatelessWidget {
  final DmConversation conv;
  final VoidCallback   onTap;

  const _ConversationTile({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = conv.unreadByPatient;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryExtraLight,
              ),
              child: ClipOval(
                child: conv.doctorImageUrl.isNotEmpty
                    ? Image.network(
                        conv.doctorImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.doctorName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: unread > 0
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conv.lastMessageAt != null)
                        Text(
                          _formatTimestamp(conv.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: unread > 0
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                unread > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage.isEmpty
                              ? 'Start the conversation'
                              : conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: unread > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.orangeGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(dt.year, dt.month, dt.day);

    if (d == today) {
      final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m    = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SKELETON TILE
// ══════════════════════════════════════════════════════════════════════════════

class _ConversationTileSkeleton extends StatefulWidget {
  const _ConversationTileSkeleton();
  @override
  State<_ConversationTileSkeleton> createState() =>
      _ConversationTileSkeletonState();
}

class _ConversationTileSkeletonState extends State<_ConversationTileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.borderGray,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}