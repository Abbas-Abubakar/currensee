import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currensee/core/utils/validators.dart';
import 'package:currensee/providers/auth_provider.dart';
import 'package:currensee/widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
    );

    if (!success && mounted) {
      final error = ref.read(authNotifierProvider.notifier).getErrorMessage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed. Please try again.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF202124)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ─── Header ───────────────────────────────────────────────
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Join CurrenSee today',
                  style: TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
                ),

                const SizedBox(height: 36),

                // ─── Full Name ────────────────────────────────────────────
                AuthTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: Validators.validateFullName,
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 20),

                // ─── Email ────────────────────────────────────────────────
                AuthTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 20),

                // ─── Password ─────────────────────────────────────────────
                AuthTextField(
                  label: 'Password',
                  hint: 'Create a password (min. 6 chars)',
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 20),

                // ─── Confirm Password ─────────────────────────────────────
                AuthTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  validator: (val) => Validators.validateConfirmPassword(
                      val, _passwordController.text),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 32),

                // ─── Terms Note ───────────────────────────────────────────
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                    children: [
                      TextSpan(text: 'By creating an account, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Register Button ──────────────────────────────────────
                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text('Create Account'),
                ),

                const SizedBox(height: 24),

                // ─── Login Link ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF5F6368)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF1A73E8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}