import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/lifting_provider.dart';
import 'log_lifting_screen.dart';
import '../../core/constants/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lifting Sessions')),
      body: Consumer<LiftingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.sessions.isEmpty) {
            return const Center(child: Text('No lifting sessions yet. Start logging!'));
          }

          return ListView.builder(
            itemCount: provider.sessions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(session.sessionName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${DateFormat('MMM d, yyyy').format(session.date)} • ${session.exercises.length} exercises',
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LogLiftingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
