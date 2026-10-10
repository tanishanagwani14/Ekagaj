import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/app_session.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/ek_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  LoginPortal _portal = LoginPortal.employee;
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _anim.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await AppSession.signUp(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
          username: _username.text,
          portal: _portal,
        );
      } else {
        await AppSession.signIn(
          email: _email.text,
          password: _password.text,
          portal: _portal,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authErrorMessage(Object e) {
    if (e is StateError) return e.message;
    if (e is ArgumentError) return e.message?.toString() ?? e.toString();
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'wrong-password' => 'Incorrect password.',
        'user-not-found' => 'No account found. Tap "Create account" to register.',
        'invalid-email' => 'Enter a valid email address.',
        'invalid-credential' => 'Invalid email or password.',
        'email-already-in-use' => 'This email is already registered. Try Sign In.',
        'weak-password' => 'Password must be at least 6 characters.',
        'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
        _ => e.message ?? 'Authentication failed. Please try again.',
      };
    }
    final text = e.toString();
    if (text.contains('permission-denied') || text.contains('unavailable')) {
      return 'Could not reach the server. Check your internet and try again.';
    }
    return 'Authentication failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = context.ekCardSurface;
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;
    final inputFill = context.ekInputFill;
    final isAdmin = _portal == LoginPortal.admin;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAdmin
                ? const [Color(0xFF312E81), EkColors.purple600, Color(0xFF7C3AED), Color(0xFF4C1D95)]
                : const [Color(0xFF0C4A6E), EkColors.blue500, Color(0xFF2563EB), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      const EkLogo(height: 88, maxWidth: 220),
                      const SizedBox(height: 16),
                      Text(
                        'Ekagaj',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: Row(
                          children: [
                            _PortalChip(
                              label: 'Employee',
                              icon: Icons.person_outline_rounded,
                              selected: !isAdmin,
                              onTap: () => setState(() {
                                _portal = LoginPortal.employee;
                                _errorMessage = null;
                              }),
                            ),
                            _PortalChip(
                              label: 'Admin',
                              icon: Icons.shield_outlined,
                              selected: isAdmin,
                              onTap: () => setState(() {
                                _portal = LoginPortal.admin;
                                _errorMessage = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                isAdmin
                                    ? (_isSignUp ? 'Create admin account' : 'Admin sign in')
                                    : (_isSignUp ? 'Join your team' : 'Employee sign in'),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              if (isAdmin) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Manage employees, tasks, and organization data',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                ),
                              ] else if (!_isSignUp) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Use the work email and password your admin gave you.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                ),
                              ] else ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Only if your admin added you without a password. Use the same work email they registered.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                ),
                              ],
                              const SizedBox(height: 22),
                              if (_isSignUp) ...[
                                _Field(
                                  controller: _name,
                                  label: 'Full name',
                                  icon: Icons.person_outline_rounded,
                                  fill: inputFill,
                                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter your name' : null,
                                ),
                                const SizedBox(height: 14),
                                _Field(
                                  controller: _username,
                                  label: 'Username',
                                  icon: Icons.alternate_email_rounded,
                                  fill: inputFill,
                                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Choose a username' : null,
                                ),
                                const SizedBox(height: 14),
                              ],
                              _Field(
                                controller: _email,
                                label: 'Work email',
                                icon: Icons.mail_outline_rounded,
                                fill: inputFill,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'Enter your email';
                                  if (!value.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _Field(
                                controller: _password,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                fill: inputFill,
                                obscure: _obscurePassword,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: textSecondary,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  final value = v?.trim() ?? '';
                                  if (value.isEmpty) return 'Enter your password';
                                  if (_isSignUp && value.length < 6) return 'Min. 6 characters';
                                  return null;
                                },
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 14),
                                _ErrorBanner(message: _errorMessage!),
                              ],
                              const SizedBox(height: 22),
                              _GradientButton(
                                label: _isSignUp ? 'Create Account' : 'Sign In',
                                loading: _isLoading,
                                colors: isAdmin
                                    ? const [EkColors.purple600, Color(0xFF9333EA)]
                                    : const [EkColors.blue500, Color(0xFF2563EB)],
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => setState(() {
                                          _isSignUp = !_isSignUp;
                                          _errorMessage = null;
                                        }),
                                child: Text(
                                  _isSignUp
                                      ? 'Already registered? Sign in'
                                      : "New here? Create account",
                                  style: TextStyle(
                                    color: isAdmin ? EkColors.purple600 : EkColors.blue500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalChip extends StatelessWidget {
  const _PortalChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? EkColors.purple600 : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? EkColors.purple600 : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.fill,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color fill;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: EkColors.purple600),
        suffixIcon: suffix,
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.loading,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final List<Color> colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: colors.last.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 52,
            child: Center(
              child: loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
