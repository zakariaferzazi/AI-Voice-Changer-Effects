import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer/providers/app_provider.dart';
import 'package:voice_changer/services/api_service.dart';
import 'package:voice_changer/models/voice_model.dart';
import 'package:voice_changer/widgets/recorder_widget.dart';

class CelebrityVoiceScreen extends StatefulWidget {
  const CelebrityVoiceScreen({super.key});

  @override
  State<CelebrityVoiceScreen> createState() => _CelebrityVoiceScreenState();
}

class _CelebrityVoiceScreenState extends State<CelebrityVoiceScreen> {
  late Future<List<Voice>> _voicesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _voicesFuture = _apiService.getVoices();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '1. Select a Voice',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Voice>>(
            future: _voicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final voices = snapshot.data ?? [];
              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: voices.length,
                  itemBuilder: (context, index) {
                    final voice = voices[index];
                    final isSelected =
                        appProvider.selectedVoice?.voiceId == voice.voiceId;
                    return GestureDetector(
                      onTap: () => appProvider.selectVoice(voice),
                      child: Card(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.5)
                            : Theme.of(context).cardColor,
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              voice.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            '2. Record or Import Audio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const RecorderWidget(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: appProvider.currentRecordingPath != null &&
                    appProvider.selectedVoice != null &&
                    !appProvider.isLoading
                ? () => appProvider.applyVoiceChange()
                : null,
            icon: appProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.transform),
            label: Text(
                appProvider.isLoading ? 'Applying...' : 'Apply Voice Change'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
