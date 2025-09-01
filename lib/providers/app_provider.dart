import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:voice_changer/services/api_service.dart';
import 'package:voice_changer/models/voice_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class AppProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();

  bool _isRecording = false;
  String? _currentRecordingPath;
  List<File> _savedFiles = [];
  bool _isLoading = false;
  Voice? _selectedVoice;

  bool get isRecording => _isRecording;
  bool get isPlaying => _audioPlayer.playing;
  String? get currentRecordingPath => _currentRecordingPath;
  List<File> get savedFiles => _savedFiles;
  bool get isLoading => _isLoading;
  Voice? get selectedVoice => _selectedVoice;
  AudioPlayer get audioPlayer => _audioPlayer;

  AppProvider() {
    loadSavedFiles();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        notifyListeners();
      }
    });
  }

  void selectVoice(Voice voice) {
    _selectedVoice = voice;
    notifyListeners();
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(const RecordConfig(), path: path);
      _isRecording = true;
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    final path = await _audioRecorder.stop();
    _isRecording = false;
    if (path != null) {
      _currentRecordingPath = path;
      await _audioPlayer.setFilePath(path);
    }
    notifyListeners();
  }

  Future<void> playRecording(String? path) async {
    if (path == null) return;
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.setFilePath(path);
    await _audioPlayer.play();
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    notifyListeners();
  }

  Future<void> applyVoiceChange() async {
    if (_currentRecordingPath == null || _selectedVoice == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final outputFile = await _apiService.convertVoice(
        File(_currentRecordingPath!),
        _selectedVoice!.voiceId,
      );
      _currentRecordingPath = outputFile.path;
      await saveFile(outputFile);
    } catch (e) {
      // Handle error
      print("Error applying voice change: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      _currentRecordingPath = result.files.single.path;
      await _audioPlayer.setFilePath(_currentRecordingPath!);
      notifyListeners();
    }
  }

  Future<void> saveFile(File file) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath = p.join(directory.path, p.basename(file.path));
    final savedFile = await file.copy(newPath);
    _savedFiles.add(savedFile);
    notifyListeners();
  }

  Future<void> loadSavedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().whereType<File>().toList();
    _savedFiles = files;
    notifyListeners();
  }

  Future<void> deleteFile(File file) async {
    await file.delete();
    _savedFiles.remove(file);
    notifyListeners();
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
