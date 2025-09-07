import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/elevenlabs_service.dart';
import 'package:voice_changer_app/services/file_service.dart';
import 'package:voice_changer_app/utils/constants.dart';

class CelebrityVoiceScreen extends StatefulWidget {
  const CelebrityVoiceScreen({super.key});

  @override
  State<CelebrityVoiceScreen> createState() => _CelebrityVoiceScreenState();
}

class _CelebrityVoiceScreenState extends State<CelebrityVoiceScreen> {
  String? _selectedVoiceId;
  String? _convertedAudioPath;
  bool _apiKeyWarningShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_apiKeyWarningShown) {
      final elevenLabsService =
          Provider.of<ElevenLabsService>(context, listen: false);
      if (elevenLabsService.elevenLabsApiKey == 'YOUR_ELEVENLABS_API_KEY') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Warning: ElevenLabs API Key is not set. Please update lib/utils/constants.dart'),
              duration: Duration(seconds: 5),
            ),
          );
        });
        _apiKeyWarningShown = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AudioService, ElevenLabsService, FileService>(
      builder: (context, audioService, elevenLabsService, fileService, child) {
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
              elevenLabsService.isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      hint: const Text('Select a Celebrity Voice'),
                      value: _selectedVoiceId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedVoiceId = newValue;
                        });
                      },
                      items: elevenLabsService.voices
                          .map<DropdownMenuItem<String>>((voice) {
                        return DropdownMenuItem<String>(
                          value: voice['voice_id'],
                          child: Text(voice['name']),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: audioService.recordedFilePath != null &&
                        _selectedVoiceId != null &&
                        !elevenLabsService.isLoading
                    ? () async {
                        final convertedPath =
                            await elevenLabsService.convertAudio(
                          audioFilePath: audioService.recordedFilePath!,
                          voiceId: _selectedVoiceId!,
                        );
                        setState(() {
                          _convertedAudioPath = convertedPath;
                        });
                        if (_convertedAudioPath != null) {
                          audioService.startPlayback(
                              filePath: _convertedAudioPath!);
                        }
                      }
                    : null,
                icon: const Icon(Icons.transform),
                label: const Text('Convert Voice'),
              ),
              if (_convertedAudioPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                      'Converted File: ${_convertedAudioPath!.split('/').last}'),
                ),
              if (_convertedAudioPath != null)
                ElevatedButton.icon(
                  onPressed: audioState == AudioState.playing
                      ? audioService.stopPlayback
                      : () => audioService.startPlayback(
                          filePath: _convertedAudioPath!),
                  icon: Icon(audioState == AudioState.playing
                      ? Icons.stop
                      : Icons.play_arrow),
                  label: Text(audioState == AudioState.playing
                      ? 'Stop Converted'
                      : 'Play Converted'),
                ),
              if (_convertedAudioPath != null)
                ElevatedButton.icon(
                  onPressed: elevenLabsService.isLoading
                      ? null
                      : () async {
                          await fileService.saveAudioFile(_convertedAudioPath!,
                              fileName:
                                  'celebrity_voice_${DateTime.now().millisecondsSinceEpoch}.mp3');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Converted audio saved!')),
                          );
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Converted'),
                ),
            ],
          ),
        );
      },
    );
  }
}
