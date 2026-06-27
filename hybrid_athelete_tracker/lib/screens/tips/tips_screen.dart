import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tips_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TipsProvider>().fetchWeeklyTip();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Tips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TipsProvider>().fetchWeeklyTip();
            },
          ),
        ],
      ),
      body: Consumer<TipsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentTip == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final tip = provider.currentTip;
          if (tip == null) {
            return const Center(child: Text('Log some data to get personalized tips!'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('AI Coach Insights', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tip['tipText'] ?? '',
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Based on your last 7 days of activity',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text('Chat with AI Coach', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
      ),
    );
  }
}
