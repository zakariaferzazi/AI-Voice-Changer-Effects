import 'package:flutter/material.dart';
import 'package:voice_changer/widgets/recorder_widget.dart';

class VoiceEffectsScreen extends StatelessWidget {
  const VoiceEffectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for real-time effects.
    // For real-time effects, you would typically use a package like `flutter_sound`
    // with its audio processing capabilities or integrate a native library.
    // The current implementation focuses on post-processing via API.
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Real-time Voice Effects',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          RecorderWidget(),
          SizedBox(height: 20),
          Text(
            'Select an effect below to apply during playback (feature coming soon).',
            textAlign: TextAlign.center,
          ),
          // Placeholder for effect selection
        ],
      ),
    );
  }
}
