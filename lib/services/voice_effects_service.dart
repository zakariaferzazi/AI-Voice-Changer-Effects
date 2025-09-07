import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class VoiceEffect {
  final String id;
  final String name;
  final String description;

  VoiceEffect({
    required this.id,
    required this.name,
    required this.description,
  });
}

class VoiceEffectsService with ChangeNotifier {
  List<VoiceEffect> _availableEffects = [
    VoiceEffect(
        id: 'robot', name: 'Robot', description: 'Mechanical robotic voice'),
    VoiceEffect(
        id: 'alien', name: 'Alien', description: 'High-pitched alien voice'),
    VoiceEffect(id: 'baby', name: 'Baby', description: 'Cute baby voice'),
    VoiceEffect(
        id: 'deep_voice',
        name: 'Deep Voice',
        description: 'Deep, low-pitched voice'),
    VoiceEffect(
        id: 'echo', name: 'Echo', description: 'Voice with echo effect'),
  ];
  bool _isLoading = false;

  List<VoiceEffect> get availableEffects => _availableEffects;
  bool get isLoading => _isLoading;

  // Apply voice effects using audio file manipulation
  Future<String?> applyEffect({
    required String audioFilePath,
    required String effectId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Applying effect "$effectId" to $audioFilePath');

      // Read the original audio file
      final File inputFile = File(audioFilePath);
      if (!await inputFile.exists()) {
        debugPrint('Input file does not exist: $audioFilePath');
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Get temporary directory for output file
      final directory = await getTemporaryDirectory();
      final outputPath =
          '${directory.path}/effect_${effectId}_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Apply the effect by modifying the audio file
      bool success =
          await _processAudioWithEffect(audioFilePath, outputPath, effectId);

      if (success) {
        debugPrint('Effect applied successfully: $outputPath');
        _isLoading = false;
        notifyListeners();
        return outputPath;
      } else {
        debugPrint('Failed to apply effect');
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      debugPrint('Error applying effect: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> _processAudioWithEffect(
      String inputPath, String outputPath, String effectId) async {
    try {
      final File inputFile = File(inputPath);
      final List<int> audioData = await inputFile.readAsBytes();

      // Create a modified version based on the effect
      List<int> modifiedData;

      switch (effectId) {
        case 'robot':
          modifiedData = _applyRobotEffect(audioData);
          break;
        case 'alien':
          modifiedData = _applyAlienEffect(audioData);
          break;
        case 'baby':
          modifiedData = _applyBabyEffect(audioData);
          break;
        case 'deep_voice':
          modifiedData = _applyDeepVoiceEffect(audioData);
          break;
        case 'echo':
          modifiedData = _applyEchoEffect(audioData);
          break;
        default:
          modifiedData = audioData; // No effect
      }

      // Write the modified data to output file
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(modifiedData);

      return true;
    } catch (e) {
      debugPrint('Error in _processAudioWithEffect: $e');
      return false;
    }
  }

  List<int> _applyRobotEffect(List<int> audioData) {
    // Robot effect: Add digital distortion by modifying bytes
    List<int> modifiedData = List.from(audioData);
    final Random random = Random();

    // Skip header bytes (typically first 100 bytes contain metadata)
    for (int i = 100; i < modifiedData.length; i += 4) {
      if (i < modifiedData.length) {
        // Add robotic distortion by quantizing the audio data
        int originalValue = modifiedData[i];
        int quantizedValue =
            (originalValue ~/ 32) * 32; // Quantize to create digital effect
        modifiedData[i] = quantizedValue.clamp(0, 255);

        // Add some random digital noise
        if (random.nextDouble() < 0.1) {
          modifiedData[i] =
              (modifiedData[i] + random.nextInt(20) - 10).clamp(0, 255);
        }
      }
    }

    return modifiedData;
  }

  List<int> _applyAlienEffect(List<int> audioData) {
    // Alien effect: High frequency modulation
    List<int> modifiedData = List.from(audioData);

    for (int i = 100; i < modifiedData.length; i += 2) {
      if (i < modifiedData.length) {
        // Apply high-frequency modulation
        double phase = (i / 100.0) * 2 * pi;
        int modulation =
            (sin(phase * 8) * 30).round(); // High frequency modulation
        modifiedData[i] = (modifiedData[i] + modulation).clamp(0, 255);
      }
    }

    return modifiedData;
  }

  List<int> _applyBabyEffect(List<int> audioData) {
    // Baby effect: Softer tones by reducing amplitude variations
    List<int> modifiedData = List.from(audioData);

    for (int i = 100; i < modifiedData.length; i++) {
      if (i < modifiedData.length) {
        // Reduce amplitude and add sweetness
        int originalValue = modifiedData[i];
        int center = 128;
        int deviation = originalValue - center;
        int softened =
            center + (deviation * 0.7).round(); // Reduce amplitude by 30%
        modifiedData[i] = softened.clamp(0, 255);
      }
    }

    return modifiedData;
  }

  List<int> _applyDeepVoiceEffect(List<int> audioData) {
    // Deep voice effect: Enhance lower frequencies
    List<int> modifiedData = List.from(audioData);

    for (int i = 100; i < modifiedData.length; i += 3) {
      if (i < modifiedData.length) {
        // Enhance bass by amplifying certain patterns
        int originalValue = modifiedData[i];
        int enhanced = (originalValue * 1.3).round(); // Amplify
        modifiedData[i] = enhanced.clamp(0, 255);

        // Add some bass harmonics
        if (i + 1 < modifiedData.length) {
          modifiedData[i + 1] = ((modifiedData[i + 1] + originalValue * 0.2))
              .round()
              .clamp(0, 255);
        }
      }
    }

    return modifiedData;
  }

  List<int> _applyEchoEffect(List<int> audioData) {
    // Echo effect: Add delayed repetition
    List<int> modifiedData = List.from(audioData);
    int delayOffset = 8000; // Delay in bytes (simulates time delay)

    for (int i = 100; i < modifiedData.length - delayOffset; i++) {
      if (i + delayOffset < modifiedData.length) {
        // Add echo by mixing current sample with delayed sample
        int original = modifiedData[i];
        int delayed = modifiedData[i + delayOffset];
        int mixed = ((original * 0.7) + (delayed * 0.3)).round();
        modifiedData[i + delayOffset] = mixed.clamp(0, 255);
      }
    }

    return modifiedData;
  }
}
