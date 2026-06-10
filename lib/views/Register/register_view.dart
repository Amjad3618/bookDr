import 'dart:io';

import 'package:bookdr/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  File? _profileImage;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<PatientAuthProvider>(
        builder: (_, auth, __) => Stack(
          children: [
            // Orange header
            Container(
              height: 160,
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
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Step 1 of 1',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Error banner ────────────────────────────────────────────
                            if (auth.errorMessage != null) ...[
                              _errorBanner(auth.errorMessage!, () {}),
                              const SizedBox(height: 12),
                            ],

                            // ── Profile photo ───────────────────────────────────────────
                            Center(child: _buildAvatarPicker(auth)),
                            const SizedBox(height: 24),

                            // ── Name ─────────────────────────────────────────────────────
                            _label('Full Name'),
                            _field(
                              _nameCtrl,
                              'e.g. Ali Raza',
                              Icons.person_outline_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Full name is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // ── Email ─────────────────────────────────────────────────────
                            _label('Email Address'),
                            _field(
                              _emailCtrl,
                              'you@example.com',
                              Icons.email_outlined,
                              type: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Email is required';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Phone ─────────────────────────────────────────────────────
                            _label('Phone Number'),
                            _field(
                              _phoneCtrl,
                              '03XX-XXXXXXX',
                              Icons.phone_outlined,
                              type: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Phone is required';
                                if (v.trim().length < 10)
                                  return 'Enter a valid phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Password ──────────────────────────────────────────────────
                            _label('Password'),
                            _passField(
                              _passCtrl,
                              'Min 8 characters',
                              _obscurePass,
                              () =>
                                  setState(() => _obscurePass = !_obscurePass),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Password is required';
                                if (v.length < 8)
                                  return 'At least 8 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // ── Confirm password ──────────────────────────────────────────
                            _label('Confirm Password'),
                            _passField(
                              _confirmCtrl,
                              'Re-enter your password',
                              _obscureConfirm,
                              () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Please confirm your password';
                                if (v != _passCtrl.text)
                                  return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // ── Terms ─────────────────────────────────────────────────────
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _acceptTerms = !_acceptTerms),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _acceptTerms
                                      ? AppColors.primaryExtraLight
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _acceptTerms
                                        ? AppColors.primary
                                        : AppColors.borderGray,
                                    width: _acceptTerms ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: _acceptTerms
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _acceptTerms
                                              ? AppColors.primary
                                              : AppColors.borderGray,
                                          width: 2,
                                        ),
                                      ),
                                      child: _acceptTerms
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'I agree to CareSync\'s Terms of Service and Privacy Policy. '
                                        'My information will be used to connect me with verified doctors.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Register button ───────────────────────────────────────────
                            _gradientBtn(
                              (!_acceptTerms || auth.isLoading)
                                  ? null
                                  : _register,
                              auth.isLoading,
                              'Create Account',
                              Icons.person_add_rounded,
                            ),
                            const SizedBox(height: 20),

                            // ── Login link ────────────────────────────────────────────────
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Already have an account?  ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Login here',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Upload/loading overlay ────────────────────────────────────────
            if (auth.isLoading || auth.isUploading) _buildOverlay(auth),
          ],
        ),
      ),
    );
  }

  // ─── Avatar picker ─────────────────────────────────────────────────────────
  Widget _buildAvatarPicker(PatientAuthProvider auth) {
    return Column(
      children: [
        GestureDetector(
          onTap: auth.isLoading ? null : _showPicker,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _profileImage != null
                        ? AppColors.primary
                        : AppColors.borderGray,
                    width: 2.5,
                  ),
                  boxShadow: _profileImage != null
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primaryExtraLight,
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: AppColors.orangeGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _profileImage != null
                        ? Icons.edit_rounded
                        : Icons.add_a_photo_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _profileImage != null
              ? 'Tap to change photo'
              : 'Add Photo (optional)',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _showPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Profile Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderGray),
            _sheetOption(
              Icons.camera_alt_rounded,
              'Take a Photo',
              AppColors.info,
              () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
            _sheetOption(
              Icons.photo_library_rounded,
              'Choose from Gallery',
              AppColors.primary,
              () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
            if (_profileImage != null)
              _sheetOption(
                Icons.delete_outline_rounded,
                'Remove Photo',
                AppColors.error,
                () {
                  Navigator.pop(context);
                  setState(() => _profileImage = null);
                },
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textTertiary,
            size: 14,
          ),
        ],
      ),
    ),
  );

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      final file = File(picked.path);
      if (await file.length() > 5 * 1024 * 1024) {
        _snack('Image must be under 5 MB', error: true);
        return;
      }
      setState(() => _profileImage = file);
    } catch (_) {
      _snack('Could not access photos. Check permissions.', error: true);
    }
  }

  Widget _buildOverlay(PatientAuthProvider auth) => Container(
    color: Colors.black.withOpacity(0.6),
    child: Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.largeShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.orangeGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                auth.isUploading
                    ? Icons.cloud_upload_rounded
                    : Icons.person_add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              auth.isUploading ? 'Uploading photo…' : 'Creating account…',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            if (auth.isUploading)
              Text(
                '${(auth.uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 14),
            auth.isUploading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: auth.uploadProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.borderGray,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  )
                : const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _snack('Please accept the Terms of Service', error: true);
      return;
    }
    FocusScope.of(context).unfocus();

    final ok = await context.read<PatientAuthProvider>().register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      profileImage: _profileImage,
    );

    if (ok && mounted) {
      Navigator.of(context).pushNamed('/Mainscreen');
    }
  }

  void _snack(String msg, {required bool error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 12))),
          ],
        ),
        backgroundColor: error ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: error ? 4 : 2),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD VIEW
// ══════════════════════════════════════════════════════════════════════════════

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          Container(
            height: 160,
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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.largeShadow,
                      ),
                      child: _sent ? _sentState() : _inputState(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sentState() => Column(
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.successLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mark_email_read_rounded,
          color: AppColors.success,
          size: 36,
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Email Sent!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'We\'ve sent a password reset link to ${_emailCtrl.text.trim()}. '
        'Check your inbox and follow the instructions.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 24),
      _gradientBtn(
        () => Navigator.pop(context),
        false,
        'Back to Login',
        Icons.login_rounded,
      ),
    ],
  );

  Widget _inputState() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email address and we\'ll send you a reset link.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        if (_error != null) ...[
          _errorBanner(_error!, () => setState(() => _error = null)),
          const SizedBox(height: 16),
        ],

        _label('Email Address'),
        _field(
          _emailCtrl,
          'you@example.com',
          Icons.email_outlined,
          type: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 24),

        _gradientBtn(
          _loading ? null : _sendReset,
          _loading,
          'Send Reset Link',
          Icons.send_rounded,
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              '← Back to Login',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await context.read<PatientAuthProvider>().forgotPassword(
      _emailCtrl.text.trim(),
    );

    setState(() {
      _loading = false;
    });

    if (error != null) {
      setState(() => _error = error);
    } else {
      setState(() => _sent = true);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED FORM HELPERS  (used across all auth screens)
// ══════════════════════════════════════════════════════════════════════════════

Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
);

Widget _field(
  TextEditingController ctrl,
  String hint,
  IconData icon, {
  TextInputType type = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: ctrl,
  keyboardType: type,
  inputFormatters: inputFormatters,
  validator: validator,
  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
  decoration: _inputDeco(hint, icon),
);

Widget _passField(
  TextEditingController ctrl,
  String hint,
  bool obscure,
  VoidCallback toggle, {
  String? Function(String?)? validator,
}) => TextFormField(
  controller: ctrl,
  obscureText: obscure,
  validator: validator,
  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
  decoration: _inputDeco(hint, Icons.lock_outline_rounded).copyWith(
    suffixIcon: IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.primary,
        size: 20,
      ),
      onPressed: toggle,
    ),
  ),
);

InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
  prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.borderGray),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.borderGray),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.error, width: 2),
  ),
  filled: true,
  fillColor: AppColors.surface,
  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
);

Widget _gradientBtn(
  VoidCallback? onTap,
  bool loading,
  String label,
  IconData icon,
) => GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      gradient: onTap != null ? AppColors.orangeGradient : null,
      color: onTap != null ? null : AppColors.disabled,
      borderRadius: BorderRadius.circular(16),
      boxShadow: onTap != null
          ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : [],
    ),
    child: Center(
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    ),
  ),
);

Widget _errorBanner(String msg, VoidCallback onClose) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: AppColors.errorLight,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.error.withOpacity(0.3)),
  ),
  child: Row(
    children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          msg,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.error,
            height: 1.4,
          ),
        ),
      ),
      GestureDetector(
        onTap: onClose,
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: 16,
        ),
      ),
    ],
  ),
);
