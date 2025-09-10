import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/foundation.dart'; // Make sure this is imported
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService with ChangeNotifier {
  FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  TextToSpeechService() {
    _initTts();
  }

  void _initTts() {
    // You can keep these handlers for extra reliability,
    // but the key fix is updating the state in speak() and stop()
    flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      debugPrint("TTS Error: $msg");
    });
  }

  Future<void> speak(String text,
      {String? language, double? pitch, double? rate}) async {
    if (text.isNotEmpty) {
      // FIX: Set the state and notify listeners at the start
      _isSpeaking = true;
      notifyListeners();

      if (language != null) {
        await flutterTts.setLanguage(language);
      }
      if (pitch != null) {
        await flutterTts.setPitch(pitch);
      }
      if (rate != null) {
        await flutterTts.setSpeechRate(rate);
      }
      await flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    // FIX: Set the state and notify listeners at the start
    _isSpeaking = false;
    notifyListeners();
    await flutterTts.stop();
  }

  Future<String?> generateAndApplyEffect({
    required String text,
    required String effectId,
  }) async {
    debugPrint('Generating speech for "$text" and applying effect "$effectId"');
    await Future.delayed(const Duration(seconds: 3));
    return null;
  }
}
