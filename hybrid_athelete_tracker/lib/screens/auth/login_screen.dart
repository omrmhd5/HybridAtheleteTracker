import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.shadowPrimary,
                      ),
                      child: const Icon(Icons.fitness_center,
                          size: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Welcome back',
                      style: AppTextStyles.heading1, textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text('Track your lifting, food, and cardio',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter your password' : null,
                  ),
                  const SizedBox(height: 24),
                  HAButton(
                    label: 'Log in',
                    fullWidth: true,
                    loading: isLoading,
                    onPressed: isLoading ? null : _login,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text('Don’t have an account? Sign up',
                        style: AppTextStyles.sans(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
