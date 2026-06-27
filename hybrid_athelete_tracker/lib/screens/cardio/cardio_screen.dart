import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cardio_provider.dart';
import 'log_cardio_screen.dart';
import '../../core/constants/app_colors.dart';

class CardioScreen extends StatefulWidget {
  const CardioScreen({super.key});

  @override
  State<CardioScreen> createState() => _CardioScreenState();
}

class _CardioScreenState extends State<CardioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardioProvider>().fetchSessions();
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'run': return Icons.directions_run;
      case 'cycle': return Icons.directions_bike;
      case 'swim': return Icons.pool;
      default: return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cardio Logs')),
      body: Consumer<CardioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.sessions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.sessions.isEmpty) {
            return const Center(child: Text('No cardio logged yet.'));
          }

          return ListView.builder(
            itemCount: provider.sessions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    child: Icon(_getIconForType(session.type), color: AppColors.primaryLight),
                  ),
                  title: Text(session.type.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${DateFormat('MMM d, yyyy').format(session.date)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${session.durationMinutes} min', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (session.distance > 0)
                        Text('${session.distance} dist', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
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
            MaterialPageRoute(builder: (context) => const LogCardioScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
