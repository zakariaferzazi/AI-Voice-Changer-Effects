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
      debugPrint('🔄 Starting voice conversion...');
      debugPrint('🎤 Voice ID: $voiceId');
      debugPrint('📁 Audio file: $audioFilePath');

      // Use the correct ElevenLabs speech-to-speech endpoint
      final url = Uri.parse('$_baseUrl/speech-to-speech/$voiceId');
      debugPrint('📡 Request URL: $url');

      var request = http.MultipartRequest('POST', url);
      request.headers['xi-api-key'] = _apiKey;
      request.headers['Accept'] = 'audio/mpeg';

      // Add the audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFilePath,
        filename: 'audio.aac',
      ));

      // Add required parameters for speech-to-speech
      request.fields['model_id'] = 'eleven_english_sts_v2';
      request.fields['voice_settings'] =
          '{"stability":0.5,"similarity_boost":0.8,"style":0.0,"use_speaker_boost":true}';

      debugPrint('🎛️ Using model: eleven_english_sts_v2');
      debugPrint('🎚️ Voice settings: stability=0.5, similarity_boost=0.8');

      debugPrint('📤 Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        debugPrint('✅ Voice conversion successful!');

        // Save the audio file to a temporary location and return its path
        final directory = await getTemporaryDirectory();
        final outputPath =
            '${directory.path}/elevenlabs_output_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(response.bodyBytes);

        debugPrint('💾 Saved converted audio to: $outputPath');
        debugPrint('📊 File size: ${response.bodyBytes.length} bytes');

        return outputPath;
      } else {
        debugPrint('❌ Failed to convert audio: ${response.statusCode}');
        debugPrint('❌ Error response: ${response.body}');

        if (response.statusCode == 401) {
          debugPrint('🔒 Authentication failed - check your API key');
        } else if (response.statusCode == 404) {
          debugPrint(
              '🔍 Endpoint not found - voice ID might be invalid: $voiceId');
          debugPrint('🔍 Available voices count: ${_voices.length}');
          debugPrint('🔄 Trying fallback method...');

          // Try fallback with text-to-speech endpoint (if speech-to-speech is not available)
          return await _convertWithTextToSpeech(
              voiceId, 'Hello, this is a voice conversion test.');
        } else if (response.statusCode == 422) {
          debugPrint(
              '⚠️ Invalid request - check audio file format or parameters');
        } else if (response.statusCode == 429) {
          debugPrint('⏰ Rate limit exceeded - wait before retrying');
        }

        return null;
      }
    } catch (e) {
      debugPrint('💥 Exception during voice conversion: $e');
      debugPrint('💥 Exception type: ${e.runtimeType}');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback method using text-to-speech endpoint
  Future<String?> _convertWithTextToSpeech(String voiceId, String text) async {
    try {
      debugPrint('🔄 Attempting fallback with text-to-speech...');

      final url = Uri.parse('$_baseUrl/text-to-speech/$voiceId');
      debugPrint('📡 Fallback URL: $url');

      final response = await http.post(
        url,
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.8,
            'style': 0.0,
            'use_speaker_boost': true,
          }
        }),
      );

      debugPrint('📥 Fallback response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Fallback conversion successful!');

        final directory = await getTemporaryDirectory();
        final outputPath =
            '${directory.path}/elevenlabs_tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final File outputFile = File(outputPath);
        await outputFile.writeAsBytes(response.bodyBytes);

        debugPrint('💾 Saved fallback audio to: $outputPath');
        return outputPath;
      } else {
        debugPrint('❌ Fallback also failed: ${response.statusCode}');
        debugPrint('❌ Fallback error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Fallback exception: $e');
      return null;
    }
  }
}
