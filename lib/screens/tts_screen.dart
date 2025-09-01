import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer/providers/app_provider.dart';
import 'package:voice_changer/services/api_service.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;

  Future<void> _generateSpeech() async {
    if (_textController.text.isEmpty) return;
    final appProvider = context.read<AppProvider>();
    if (appProvider.selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a celebrity voice first.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final file = await _apiService.textToSpeech(
        _textController.text,
        appProvider.selectedVoice!.voiceId,
      );
      await appProvider.saveFile(file);
      await appProvider.playRecording(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating speech: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Text-to-Speech',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter text here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a voice from the "Celebrity" tab.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateSpeech,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.volume_up),
            label: Text(_isGenerating ? 'Generating...' : 'Generate & Play'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
