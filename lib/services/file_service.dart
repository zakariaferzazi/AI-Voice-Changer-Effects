import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioFile {
  final String name;
  final String path;
  final DateTime createdAt;

  AudioFile({required this.name, required this.path, required this.createdAt});
}

class FileService with ChangeNotifier {
  List<AudioFile> _savedAudioFiles = [];
  bool _isLoading = false;

  List<AudioFile> get savedAudioFiles => _savedAudioFiles;
  bool get isLoading => _isLoading;

  FileService() {
    _loadSavedAudioFiles();
  }

  Future<void> _loadSavedAudioFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((item) =>
              item.path.endsWith('.aac') || item.path.endsWith('.mp3'))
          .toList();
      _savedAudioFiles = files
          .map((file) => AudioFile(
                name: file.path.split('/').last,
                path: file.path,
                createdAt: file.statSync().changed,
              ))
          .toList();
      _savedAudioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading saved audio files: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> saveAudioFile(String originalFilePath,
      {String? fileName}) async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Storage permission not granted');
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final newFileName = fileName ??
          'saved_audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final newFilePath = '${directory.path}/$newFileName';

      final File originalFile = File(originalFilePath);
      if (await originalFile.exists()) {
        await originalFile.copy(newFilePath);
        _loadSavedAudioFiles(); // Refresh the list
        return newFilePath;
      }
    } catch (e) {
      debugPrint('Error saving audio file: $e');
    }
    return null;
  }

  Future<void> importAudioFile() async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      debugPrint('Storage permission not granted');
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFilePath = result.files.single.path!;
        await saveAudioFile(pickedFilePath, fileName: result.files.single.name);
      }
    } catch (e) {
      debugPrint('Error importing audio file: $e');
    }
  }

  Future<void> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        _loadSavedAudioFiles(); // Refresh the list
      }
    } catch (e) {
      debugPrint('Error deleting audio file: $e');
    }
  }
}
