import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/common.dart';

class RegisterScreen extends StatefulWidget {
  /// Optional onboarding-derived defaults: {dailyProteinGoal, unitPreference}.
  final Map<String, dynamic>? prefill;

  const RegisterScreen({super.key, this.prefill});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _unitPreference;

  @override
  void initState() {
    super.initState();
    final unit = widget.prefill?['unitPreference'] as String?;
    _unitPreference = unit == 'lb' ? 'lbs' : (unit ?? 'kg');
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'unitPreference': _unitPreference,
    };
    final protein = widget.prefill?['dailyProteinGoal'];
    if (protein != null) data['dailyProteinGoal'] = protein;

    final success = await authProvider.register(data);
    if (!mounted) return;
    if (success) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final protein = widget.prefill?['dailyProteinGoal'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/login'),
        ),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (protein != null) ...[
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your targets are ready — finish signing up to save them.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        HABadge('${protein}g P'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 12),
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
                  validator: (v) => v!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SectionLabel('Preferred unit'),
                ),
                SegmentedControl<String>(
                  value: _unitPreference,
                  onChanged: (v) => setState(() => _unitPreference = v),
                  options: const [
                    SegmentOption(value: 'kg', label: 'kg'),
                    SegmentOption(value: 'lbs', label: 'lbs'),
                  ],
                ),
                const SizedBox(height: 26),
                HAButton(
                  label: 'Sign up',
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading ? null : _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
