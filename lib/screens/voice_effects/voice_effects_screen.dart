import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/voice_effects_service.dart';
import 'package:voice_changer_app/services/file_service.dart';

class VoiceEffectsScreen extends StatefulWidget {
  const VoiceEffectsScreen({super.key});

  @override
  State<VoiceEffectsScreen> createState() => _VoiceEffectsScreenState();
}

class _VoiceEffectsScreenState extends State<VoiceEffectsScreen> {
  String? _selectedEffectId;
  String? _effectedAudioPath;

  @override
  Widget build(BuildContext context) {
    return Consumer3<AudioService, VoiceEffectsService, FileService>(
      builder:
          (context, audioService, voiceEffectsService, fileService, child) {
        final audioState = audioService.audioState;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current Audio State: ${audioState.toString().split('.').last}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              if (audioState == AudioState.recording)
                StreamBuilder<double>(
                  stream: audioService.decibelStream,
                  builder: (context, snapshot) {
                    final decibels =
                        snapshot.data ?? -100.0; // Default to a low value
                    double normalizedDecibels = ((decibels + 60) / 60)
                        .clamp(0.0, 1.0); // Normalize to 0-1 range
                    return Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.8 *
                              normalizedDecibels,
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    onPressed: audioState == AudioState.recording
                        ? audioService.stopRecording
                        : audioService.startRecording,
                    label: Text(audioState == AudioState.recording
                        ? 'Stop Recording'
                        : 'Record Voice'),
                    icon: Icon(audioState == AudioState.recording
                        ? Icons.stop
                        : Icons.mic),
                    backgroundColor: audioState == AudioState.recording
                        ? Colors.red
                        : Colors.blue,
                  ),
                  FloatingActionButton.extended(
                    onPressed: audioState == AudioState.playing
                        ? audioService.stopPlayback
                        : (audioService.recordedFilePath != null &&
                                audioState != AudioState.recording
                            ? () => audioService.startPlayback(
                                filePath: audioService.recordedFilePath!)
                            : null),
                    label: Text(audioState == AudioState.playing
                        ? 'Stop Playback'
                        : 'Play Recorded'),
                    icon: Icon(audioState == AudioState.playing
                        ? Icons.stop
                        : Icons.play_arrow),
                    backgroundColor: audioState == AudioState.playing
                        ? Colors.orange
                        : Colors.green,
                  ),
                ],
              ),
              if (audioService.recordedFilePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'Recorded File: ${audioService.recordedFilePath!.split('/').last}'),
                ),
              const SizedBox(height: 30),
              DropdownButton<String>(
                hint: const Text('Select a Voice Effect'),
                value: _selectedEffectId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEffectId = newValue;
                    _effectedAudioPath =
                        null; // Reset effected path on new selection
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
              ElevatedButton.icon(
                onPressed: audioService.recordedFilePath != null &&
                        _selectedEffectId != null &&
                        audioState != AudioState.recording &&
                        !voiceEffectsService.isLoading
                    ? () async {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                    'Applying ${voiceEffectsService.availableEffects.firstWhere((e) => e.id == _selectedEffectId).name} effect...'),
                              ],
                            ),
                            duration: const Duration(seconds: 10),
                          ),
                        );

                        final effectedPath =
                            await voiceEffectsService.applyEffect(
                          audioFilePath: audioService.recordedFilePath!,
                          effectId: _selectedEffectId!,
                        );

                        // Hide loading snackbar
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        setState(() {
                          _effectedAudioPath = effectedPath;
                        });

                        if (_effectedAudioPath != null) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Voice effect applied successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Automatically play the effected audio
                          audioService.startPlayback(
                              filePath: _effectedAudioPath!);
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to apply voice effect. Please try again.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    : null,
                icon: voiceEffectsService.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.waves),
                label: Text(voiceEffectsService.isLoading
                    ? 'Processing...'
                    : 'Apply Effect'),
              ),
              if (_effectedAudioPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'Effected File: ${_effectedAudioPath!.split('/').last}'),
                ),
              if (_effectedAudioPath != null)
                ElevatedButton.icon(
                  onPressed: audioState == AudioState.playing
                      ? audioService.stopPlayback
                      : () => audioService.startPlayback(
                          filePath: _effectedAudioPath!),
                  icon: Icon(audioState == AudioState.playing
                      ? Icons.stop
                      : Icons.play_arrow),
                  label: Text(audioState == AudioState.playing
                      ? 'Stop Effected'
                      : 'Play Effected'),
                ),
              if (_effectedAudioPath != null)
                ElevatedButton.icon(
                  onPressed: voiceEffectsService.isLoading
                      ? null
                      : () async {
                          await fileService.saveAudioFile(_effectedAudioPath!,
                              fileName:
                                  'voice_effect_${_selectedEffectId}_${DateTime.now().millisecondsSinceEpoch}.aac');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Effected audio saved!')),
                          );
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Effected'),
                ),
            ],
          ),
        );
      },
    );
  }
}
