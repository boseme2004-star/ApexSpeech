import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:apex_speech/core/constants/app_constants.dart';
import 'package:apex_speech/core/themes/app_theme.dart';
import 'package:apex_speech/core/utils/validators.dart';
import 'package:apex_speech/presentation/viewmodels/auth_viewmodel.dart';
import 'package:apex_speech/presentation/widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? AppConstants.genericError),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return ApexScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ─── Brand Header ─────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 48),

              // ─── Glass Form Card ──────────────────────────────
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to continue your journey',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline_rounded,
                              color: AppTheme.textMuted),
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppTheme.textMuted),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        validator: Validators.validatePassword,
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 32),

                      GoldButton(
                        label: 'Sign In',
                        isLoading: authVM.isLoading,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // ─── Sign Up Link ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                        context, AppConstants.signupRoute),
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.goldAccent,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gold apex icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.record_voice_over_rounded,
            color: AppTheme.primary,
            size: 28,
          ),
        ).animate().scale(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 20),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.goldAccent,
              ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
        const SizedBox(height: 6),
        Text(
          'Your AI Public Speaking Coach',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }
}
