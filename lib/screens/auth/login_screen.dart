import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Login screen with email/password validation and dummy API integration.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'test@brain.com');
  final _passCtrl = TextEditingController(text: 'password123');
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
    _loadSavedCredentials();
  }

  /// Load saved credentials if remember me was enabled
  Future<void> _loadSavedCredentials() async {
    final storage = StorageService();
    await storage.init();
    if (storage.isRememberEnabled) {
      setState(() {
        _rememberMe = true;
        _emailCtrl.text = storage.rememberEmail;
        _passCtrl.text = storage.rememberPassword;
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Save or clear credentials based on remember me checkbox
    final storage = StorageService();
    await storage.init();
    await storage.setRememberMe(_rememberMe, _emailCtrl.text.trim(), _passCtrl.text);
    
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      // Navigate to main app - handled by AuthGate in main.dart
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────────
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // ── Fields ───────────────────────────────────────────────
                    AppTextField(
                      hint: 'Enter your email',
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hint: 'Enter your password',
                      label: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      controller: _passCtrl,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _login,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),

                    // ── Error message ─────────────────────────────────────
                    if (auth.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(auth.errorMessage!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Sign In',
                      onTap: _login,
                      isLoading: auth.isLoading,
                    ),
                    const SizedBox(height: 28),

                    // ── Divider ────────────────────────────────────────────
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 20),

                    // ── Demo login hint ─────────────────────────────────
                    _DemoHintCard(),
                    const SizedBox(height: 28),

                    // ── Register link ──────────────────────────────────────
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Don't have an account?  ",
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text('Register',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            )),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Image.asset(
        'assets/logo.png',
        width: 64,
        height: 64,
      ),
      const SizedBox(height: 24),
      const Text('Welcome back! 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          )),
      const SizedBox(height: 6),
      const Text('Sign in to continue training your brain',
          style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              height: 1.5)),
    ]);
  }
}

/// Hint card showing demo credentials.
class _DemoHintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Demo: test@brain.com / password123',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
    );
  }
}
