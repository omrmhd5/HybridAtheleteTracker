import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/lifting_provider.dart';
import '../../models/lifting_session_model.dart';
import '../../widgets/lifting/exercise_entry_tile.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class LogLiftingScreen extends StatefulWidget {
  const LogLiftingScreen({super.key});

  @override
  State<LogLiftingScreen> createState() => _LogLiftingScreenState();
}

class _LogLiftingScreenState extends State<LogLiftingScreen> {
  final _sessionNameController = TextEditingController(text: 'Workout');
  final List<ExerciseEntryData> _exercises = [ExerciseEntryData()];
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceTranscript = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(ExerciseEntryData());
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceTranscript = val.recognizedWords;
            // A simple regex parser could go here for MVP
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _saveSession() async {
    final liftingProvider = Provider.of<LiftingProvider>(context, listen: false);

    List<ExerciseModel> parsedExercises = _exercises.map((eData) {
      return ExerciseModel(
        name: eData.name.isEmpty ? 'Unnamed Exercise' : eData.name,
        sets: eData.sets.map((sData) {
          return SetModel(
            reps: int.tryParse(sData.repsController.text) ?? 0,
            weight: double.tryParse(sData.weightController.text) ?? 0.0,
          );
        }).toList(),
      );
    }).toList();

    final session = LiftingSessionModel(
      id: '',
      date: DateTime.now(),
      sessionName: _sessionNameController.text,
      exercises: parsedExercises,
      voiceTranscript: _voiceTranscript.isNotEmpty ? _voiceTranscript : null,
    );

    final success = await liftingProvider.logSession(session);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<LiftingProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isLoading ? null : _saveSession,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _sessionNameController,
                style: AppTextStyles.heading2,
                decoration: const InputDecoration(
                  hintText: 'Workout Name',
                  border: InputBorder.none,
                  filled: false,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            
            if (_voiceTranscript.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Transcript: $_voiceTranscript', style: AppTextStyles.bodyMedium),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return ExerciseEntryTile(
                    exerciseData: _exercises[index],
                    onRemoveExercise: () {
                      setState(() => _exercises.removeAt(index));
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? AppColors.error : AppColors.primary,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
