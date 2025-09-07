import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

enum AudioState {
  idle,
  recording,
  playing,
  paused,
  stopped,
}

class AudioService with ChangeNotifier {
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  String? _recordedFilePath;
  AudioState _audioState = AudioState.idle;
  StreamController<double>? _decibelController;
  Stream<double>? get decibelStream => _decibelController?.stream;

  AudioService() {
    _init();
  }

  AudioState get audioState => _audioState;
  String? get recordedFilePath => _recordedFilePath;

  Future<void> _init() async {
    await _initRecorder();
    await _initPlayer();
  }

  Future<void> _initRecorder() async {
    _audioRecorder = FlutterSoundRecorder();
    await _audioRecorder!.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> _initPlayer() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openPlayer();
    _isPlayerInitialized = true;
  }

  Future<void> startRecording() async {
    if (!_isRecorderInitialized) {
      await _initRecorder();
    }
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    final directory = await getApplicationDocumentsDirectory();
    _recordedFilePath =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    _decibelController = StreamController<double>();

    await _audioRecorder!.startRecorder(
      toFile: _recordedFilePath,
      codec: Codec.aacADTS,
      numChannels: 1,
      sampleRate: 44100,
    );

    _audioRecorder!.onProgress!.listen((e) {
      if (e.decibels != null) {
        _decibelController?.add(e.decibels!);
      }
    });

    _audioState = AudioState.recording;
    notifyListeners();
  }

  Future<void> stopRecording() async {
    await _audioRecorder!.stopRecorder();
    _decibelController?.close();
    _audioState = AudioState.stopped;
    notifyListeners();
  }

  Future<void> startPlayback({required String filePath}) async {
    if (!_isPlayerInitialized) {
      await _initPlayer();
    }
    if (filePath != null) {
      await _audioPlayer!.startPlayer(
        fromURI: filePath,
        whenFinished: () {
          _audioState = AudioState.stopped;
          notifyListeners();
        },
      );
      _audioState = AudioState.playing;
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    await _audioPlayer!.stopPlayer();
    _audioState = AudioState.stopped;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    _audioPlayer!.closePlayer();
    _isRecorderInitialized = false;
    _isPlayerInitialized = false;
    _decibelController?.close();
    super.dispose();
  }
}
