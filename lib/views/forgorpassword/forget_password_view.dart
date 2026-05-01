import 'package:bookdr/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});
  @override State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}
 
class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _sent = false;
  bool  _loading = false;
  String? _error;
 
  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(children: [
        Container(height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)))),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context)),
              const Expanded(child: Text('Reset Password',
                style: TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.bold))),
            ])),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.largeShadow),
              child: _sent ? _sentState() : _inputState(),
            ),
          )),
        ])),
      ]),
    );
  }
 
  Widget _sentState() => Column(children: [
    Container(width: 72, height: 72,
      decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
      child: const Icon(Icons.mark_email_read_rounded,
        color: AppColors.success, size: 36)),
    const SizedBox(height: 16),
    const Text('Email Sent!', style: TextStyle(fontSize: 20,
      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    Text(
      'We\'ve sent a password reset link to ${_emailCtrl.text.trim()}. '
      'Check your inbox and follow the instructions.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
    const SizedBox(height: 24),
    _gradientBtn(() => Navigator.pop(context), false, 'Back to Login', Icons.login_rounded),
  ]);
 
  Widget _inputState() => Form(key: _formKey, child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 56, height: 56,
      decoration: BoxDecoration(color: AppColors.primaryExtraLight, shape: BoxShape.circle),
      child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 28)),
    const SizedBox(height: 16),
    const Text('Forgot Password?', style: TextStyle(fontSize: 20,
      fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 8),
    const Text('Enter your email address and we\'ll send you a reset link.',
      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
    const SizedBox(height: 24),
 
    if (_error != null) ...[
      _errorBanner(_error!, () => setState(() => _error = null)),
      const SizedBox(height: 16),
    ],
 
    _label('Email Address'),
    _field(_emailCtrl, 'you@example.com', Icons.email_outlined,
      type: TextInputType.emailAddress,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      }),
    const SizedBox(height: 24),
 
    _gradientBtn(_loading ? null : _sendReset, _loading,
      'Send Reset Link', Icons.send_rounded),
    const SizedBox(height: 16),
    Center(child: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Text('← Back to Login', style: TextStyle(
        color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)))),
  ]));
 
  Widget _gradientBtn(VoidCallback? onTap, bool loading, String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        icon: Icon(icon, size: 20, color: Colors.white),
        label: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
 
  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
 
    final error = await context.read<PatientAuthProvider>()
        .forgotPassword(_emailCtrl.text.trim());
 
    setState(() { _loading = false; });
 
    if (error != null) {
      setState(() => _error = error);
    } else {
      setState(() => _sent = true);
    }
  }
}
Widget _gradientBtn(VoidCallback? onTap, bool loading,
    String label, IconData icon) =>
  GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        gradient: onTap != null ? AppColors.orangeGradient : null,
        color: onTap != null ? null : AppColors.disabled,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onTap != null ? [BoxShadow(
          color: AppColors.primary.withOpacity(0.35),
          blurRadius: 12, offset: const Offset(0, 4))] : []),
      child: Center(child: loading
          ? const SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white,
                fontSize: 15, fontWeight: FontWeight.bold)),
            ])),
    ),
  );
 
Widget _errorBanner(String msg, VoidCallback onClose) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: AppColors.errorLight, borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.error.withOpacity(0.3))),
  child: Row(children: [
    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
    const SizedBox(width: 10),
    Expanded(child: Text(msg, style: const TextStyle(
      fontSize: 12, color: AppColors.error, height: 1.4))),
    GestureDetector(onTap: onClose,
      child: const Icon(Icons.close_rounded, color: AppColors.error, size: 16)),
  ]));
   
Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: const TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)));
 
Widget _field(
  TextEditingController ctrl, String hint, IconData icon, {
  TextInputType type = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: ctrl, keyboardType: type,
  inputFormatters: inputFormatters, validator: validator,
  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
  decoration: _inputDeco(hint, icon));
 
Widget _passField(
  TextEditingController ctrl, String hint, bool obscure,
  VoidCallback toggle, {String? Function(String?)? validator}) =>
TextFormField(
  controller: ctrl, obscureText: obscure, validator: validator,
  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
  decoration: _inputDeco(hint, Icons.lock_outline_rounded).copyWith(
    suffixIcon: IconButton(
      icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.primary, size: 20),
      onPressed: toggle)));
 
InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
  prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.borderGray)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.borderGray)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.primary, width: 2)),
  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.error)),
  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: AppColors.error, width: 2)),
  filled: true, fillColor: AppColors.surface,
  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16));