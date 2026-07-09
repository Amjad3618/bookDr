import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../models/dm_model.dart';
import '../../providers/dm_provider.dart';

class DmView extends StatefulWidget {
  const DmView({super.key});

  @override
  State<DmView> createState() => _DmViewState();
}

class _DmViewState extends State<DmView> {
  final _textCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker     = ImagePicker();
  bool  _hasText    = false;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(() {
      final has = _textCtrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(DmProvider prov) async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    HapticFeedback.selectionClick();
    await prov.sendMessage(text);
    _scrollToBottom();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IMAGE PICKING
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _showImageSourceSheet(DmProvider prov) async {
    HapticFeedback.selectionClick();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachmentSheet(),
    );
    if (source == null) return;
    await _pickAndSend(prov, source);
  }

  Future<void> _pickAndSend(DmProvider prov, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 78,
      );
      if (picked == null) return;
      await prov.sendImageMessage(File(picked.path));
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access camera/gallery.')),
        );
      }
    }
  }

  void _openFullScreenImage(String url) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullScreenImageViewer(imageUrl: url),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Consumer<DmProvider>(
      builder: (_, prov, __) {
        if (!prov.isLoading && prov.messages.isNotEmpty) _scrollToBottom();

        final conv = prov.conversation;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: _buildAppBar(conv),
          body: Column(
            children: [
              Expanded(child: _buildBody(prov, conv)),
              if (!prov.isLoading && prov.errorMessage == null)
                _buildInputBar(prov),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(DmConversation? conv) {
    return AppBar(
      backgroundColor: const Color(0xFFFF6B35),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: conv == null
          ? const _SkeletonAppBarTitle()
          : Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.8),
                    color: Colors.white.withOpacity(0.25),
                  ),
                  child: ClipOval(
                    child: conv.doctorImageUrl.isNotEmpty
                        ? Image.network(
                            conv.doctorImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : const Icon(Icons.person_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conv.doctorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.more_vert_rounded,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBody(DmProvider prov, DmConversation? conv) {
    // ── Loading ──────────────────────────────────────────────────────────────
    if (prov.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    // ── Error ────────────────────────────────────────────────────────────────
    if (prov.errorMessage != null) {
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
                prov.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    // ── Empty state (no messages yet) ────────────────────────────────────────
    if (prov.messages.isEmpty) {
      return _buildEmptyState(conv!);
    }

    // ── Message list ─────────────────────────────────────────────────────────
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: prov.messages.length,
      itemBuilder: (_, i) {
        final msg      = prov.messages[i];
        final isMe     = msg.senderId == conv!.patientId;
        final prevMsg  = i > 0 ? prov.messages[i - 1] : null;
        final showDate = _shouldShowDate(msg, prevMsg);
        final showName = !isMe &&
            (prevMsg == null || prevMsg.senderId != msg.senderId);

        return Column(
          children: [
            if (showDate) _DateDivider(date: msg.sentAt),
            _MessageBubble(
              message:  msg,
              isMe:     isMe,
              showName: showName,
              onTapImage: msg.isImage && msg.imageUrl != null
                  ? () => _openFullScreenImage(msg.imageUrl!)
                  : null,
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(DmMessage curr, DmMessage? prev) {
    if (prev == null) return true;
    final a = curr.sentAt;
    final b = prev.sentAt;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(DmConversation conv) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: ClipOval(
                child: conv.doctorImageUrl.isNotEmpty
                    ? Image.network(
                        conv.doctorImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 38,
                        ),
                      )
                    : const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 38),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              conv.doctorName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start the conversation! Ask the doctor about their services, availability, or anything else.',
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
  // INPUT BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildInputBar(DmProvider prov) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderGray, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 8,
        right: 12,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach (photo) button
          IconButton(
            onPressed: prov.isUploadingImage
                ? null
                : () => _showImageSourceSheet(prov),
            icon: prov.isUploadingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.add_photo_alternate_rounded,
                    color: AppColors.primary, size: 24),
          ),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: TextField(
                controller: _textCtrl,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.55),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(prov),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: _hasText ? AppColors.orangeGradient : null,
              color: _hasText ? null : AppColors.borderGray,
              shape: BoxShape.circle,
              boxShadow: _hasText
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _hasText && !prov.isSending ? () => _send(prov) : null,
                child: Center(
                  child: prov.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: _hasText
                              ? Colors.white
                              : AppColors.textSecondary,
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
// ATTACHMENT SHEET (Camera / Gallery)
// ══════════════════════════════════════════════════════════════════════════════

class _AttachmentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FULL SCREEN IMAGE VIEWER
// ══════════════════════════════════════════════════════════════════════════════

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ══════════════════════════════════════════════════════════════════════════════

class _MessageBubble extends StatelessWidget {
  final DmMessage      message;
  final bool           isMe;
  final bool           showName;
  final VoidCallback?  onTapImage;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showName,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showName && !isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                message.isImage
                    ? _buildImageBubble(context)
                    : _buildTextBubble(),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTime(message.sentAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildTextBubble() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 280,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: isMe ? AppColors.orangeGradient : null,
        color: isMe ? null : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(18),
          topRight:    const Radius.circular(18),
          bottomLeft:  Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        border: isMe ? null : Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontSize: 14,
          color: isMe ? Colors.white : AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageBubble(BuildContext context) {
    final url = message.imageUrl;
    return GestureDetector(
      onTap: onTapImage,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(16),
          topRight:    const Radius.circular(16),
          bottomLeft:  Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 220, maxHeight: 260),
          color: AppColors.borderGray,
          child: url == null || url.isEmpty
              ? const SizedBox(
                  width: 180,
                  height: 180,
                  child: Icon(Icons.broken_image_rounded,
                      color: AppColors.textSecondary),
                )
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          width: 180,
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 180,
                    height: 180,
                    child: Icon(Icons.broken_image_rounded,
                        color: AppColors.textSecondary),
                  ),
                ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h    = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m    = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DATE DIVIDER
// ══════════════════════════════════════════════════════════════════════════════

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _label() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: AppColors.borderGray, thickness: 0.8)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Text(
              _label(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
              child: Divider(color: AppColors.borderGray, thickness: 0.8)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SKELETON APP BAR TITLE
// ══════════════════════════════════════════════════════════════════════════════

class _SkeletonAppBarTitle extends StatelessWidget {
  const _SkeletonAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 50,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}