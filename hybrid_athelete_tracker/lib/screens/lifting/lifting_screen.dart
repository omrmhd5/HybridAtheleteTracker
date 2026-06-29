import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/lifting_provider.dart';
import '../../widgets/common/common.dart';
import '../home/app_route.dart';
import 'live_log_screen.dart';

class LiftingScreen extends StatefulWidget {
  const LiftingScreen({super.key});

  @override
  State<LiftingScreen> createState() => _LiftingScreenState();
}

class _LiftingScreenState extends State<LiftingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiftingProvider>().fetchSessions();
    });
  }

  void _start() => context.pushScreen(const LiveLogScreen());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<LiftingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.sessions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                const SectionLabel('Recent sessions'),
                const SizedBox(height: 10),
                if (provider.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text('No sessions yet — start your first workout.',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                  )
                else
                  for (final s in provider.sessions) ...[
                    AppCard(
                      interactive: true,
                      onTap: _start,
                      child: ListRow(
                        icon: Icons.fitness_center,
                        title: s.sessionName,
                        subtitle:
                            '${DateFormat('MMM d, yyyy').format(s.date)} · ${s.exercises.length} exercises',
                        trailing: const Icon(Icons.chevron_right,
                            size: 20, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 9),
                  ],
              ],
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: HAFab(
            icon: Icons.add,
            label: 'Start workout',
            onPressed: _start,
          ),
        ),
      ],
    );
  }
}
