import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_changer_app/utils/constants.dart';
import 'package:path_provider/path_provider.dart';

class ElevenLabsService with ChangeNotifier {
  final String _apiKey = AppConstants.elevenLabsApiKey;
  final String _baseUrl = 'https://api.elevenlabs.io/v1';
  List<Map<String, dynamic>> _voices = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get voices => _voices;
  bool get isLoading => _isLoading;
  String get elevenLabsApiKey => _apiKey; // Add this getter

  ElevenLabsService() {
    if (_apiKey == 'YOUR_ELEVENLABS_API_KEY') {
      debugPrint(
          'Warning: ElevenLabs API Key is not set. Voice conversion will not work.');
    } else {
      fetchVoices();
    }
  }

  Future<void> fetchVoices() async {
    debugPrint('🔄 Starting to fetch voices...');
    debugPrint('🔑 Using API Key: ${_apiKey.substring(0, 10)}...');

    _isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/voices');
      debugPrint('📡 Making request to: $uri');

      final response = await http.get(
        uri,
        headers: {'xi-api-key': _apiKey},
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _voices = List<Map<String, dynamic>>.from(data['voices']);
        debugPrint('✅ Successfully loaded ${_voices.length} voices');

        // Print first few voice names for debugging
        if (_voices.isNotEmpty) {
          debugPrint('🎤 Sample voices:');
          for (int i = 0; i < (_voices.length > 3 ? 3 : _voices.length); i++) {
            debugPrint(
                '   - ${_voices[i]['name']} (${_voices[i]['voice_id']})');
          }
        }
      } else {
        debugPrint('❌ Failed to load voices: ${response.statusCode}');
        debugPrint('❌ Error response: ${response.body}');

        if (response.statusCode == 401) {
          debugPrint('🔒 Authentication failed - check your API key');
        } else if (response.statusCode == 429) {
          debugPrint('⏰ Rate limit exceeded - wait before retrying');
        }
      }
    } catch (e) {
      debugPrint('💥 Exception while fetching voices: $e');
      debugPrint('💥 Exception type: ${e.runtimeType}');
    }

    _isLoading = false;
    notifyListeners();
    debugPrint('🏁 Fetch voices completed. Total voices: ${_voices.length}');
  }

  Future<String?> convertAudio({
    required String audioFilePath,
    required String voiceId,
  }) async {
    if (_apiKey == 'YOUR_ELEVENLABS_API_KEY') {
      debugPrint(
          'ElevenLabs API Key is not set. Cannot perform voice conversion.');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/voice-lab/speech-to-speech');
      var request = http.MultipartRequest('POST', url)
        ..headers['xi-api-key'] = _apiKey
        ..headers['Content-Type'] = 'multipart/form-data';

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFilePath,
        filename: 'audio.aac',
      ));
      request.fields['voice_id'] = voiceId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // ElevenLabs speech-to-speech returns an audio file directly
        // Save the audio file to a temporary location and return its path
        final directory = await getTemporaryDirectory();
        final outputPath =
            '${directory.path}/elevenlabs_output_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(response.bodyBytes);
        return outputPath;
      } else {
        debugPrint(
            'Failed to convert audio: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error converting audio: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
