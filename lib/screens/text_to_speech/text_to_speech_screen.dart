import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/services/text_to_speech_service.dart';
import 'package:voice_changer_app/services/voice_effects_service.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedEffectId;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TextToSpeechService, VoiceEffectsService>(
      builder: (context, ttsService, voiceEffectsService, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text for speech',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text(
                    'Select a Voice Effect (for future implementation)'),
                value: _selectedEffectId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEffectId = newValue;
                  });
                },
                items: voiceEffectsService.availableEffects
                    .map<DropdownMenuItem<String>>((effect) {
                  return DropdownMenuItem<String>(
                    value: effect.id,
                    child: Text(effect.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    onPressed: ttsService.isSpeaking
                        ? ttsService.stop
                        : () => ttsService.speak(_textController.text),
                    label: Text(
                        ttsService.isSpeaking ? 'Stop Speaking' : 'Speak Text'),
                    icon: Icon(
                        ttsService.isSpeaking ? Icons.stop : Icons.play_arrow),
                    backgroundColor:
                        ttsService.isSpeaking ? Colors.red : Colors.green,
                  ),
                  FloatingActionButton.extended(
                    onPressed: _textController.text.isNotEmpty &&
                            _selectedEffectId != null &&
                            !ttsService.isSpeaking
                        ? () async {
                            // This is a placeholder for combining TTS and effects.
                            // In a full implementation, this would generate audio, save it, and then apply the effect.
                            // For now, it will just speak the text.
                            // await ttsService.generateAndApplyEffect(text: _textController.text, effectId: _selectedEffectId!);
                            ttsService.speak(_textController.text);
                          }
                        : null,
                    label: const Text('Speak with Effect'),
                    icon: const Icon(Icons.volume_up),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
