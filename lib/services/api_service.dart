import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:voice_changer/models/voice_model.dart';

class ApiService {
  final String _apiKey =
      "YOUR_ELEVENLABS_API_KEY"; // <-- IMPORTANT: REPLACE WITH YOUR KEY
  final String _baseUrl = "https://api.elevenlabs.io/v1";

  Future<List<Voice>> getVoices() async {
    // This is a mock implementation. In a real app, you'd fetch this from the API.
    // Example: https://api.elevenlabs.io/v1/voices
    return [
      Voice(voiceId: "21m00Tcm4TlvDq8ikWAM", name: "Rachel"),
      Voice(voiceId: "AZnzlk1XvdvUeBnXmlld", name: "Domi"),
      Voice(voiceId: "EXAVITQu4vr4xnSDxMaL", name: "Bella"),
      Voice(voiceId: "ErXwobaYiN019PkySvjV", name: "Antoni"),
    ];
  }

  Future<File> convertVoice(File audioFile, String voiceId) async {
    final url = Uri.parse("$_baseUrl/speech-to-speech/$voiceId");
    final request = http.MultipartRequest('POST', url)
      ..headers['xi-api-key'] = _apiKey
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(
          '${tempDir.path}/converted_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await response.stream.pipe(outputFile.openWrite());
      return outputFile;
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception(
          "Failed to convert voice: ${response.statusCode} $responseBody");
    }
  }

  Future<File> textToSpeech(String text, String voiceId) async {
    final url = Uri.parse("$_baseUrl/text-to-speech/$voiceId");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': _apiKey,
      },
      body: '{"text": "$text"}',
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final outputFile = File(
          '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await outputFile.writeAsBytes(response.bodyBytes);
      return outputFile;
    } else {
      throw Exception(
          "Failed to convert text to speech: ${response.statusCode} ${response.body}");
    }
  }
}
