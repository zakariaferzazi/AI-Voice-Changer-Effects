import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer/providers/app_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class RecorderWidget extends StatefulWidget {
  const RecorderWidget({super.key});

  @override
  State<RecorderWidget> createState() => _RecorderWidgetState();
}

class _RecorderWidgetState extends State<RecorderWidget> {
  late final RecorderController _recorderController;
  late final PlayerController _playerController;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController();
    _playerController = PlayerController();
    final appProvider = context.read<AppProvider>();
    appProvider.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.ready) {
        _playerController.preparePlayer(
            path: appProvider.currentRecordingPath!);
      }
    });
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (appProvider.isRecording)
              AudioWaveforms(
                size: Size(MediaQuery.of(context).size.width, 100.0),
                recorderController: _recorderController,
                enableGesture: true,
                waveStyle: const WaveStyle(
                  waveColor: Colors.white,
                  showDurationLabel: true,
                  spacing: 8.0,
                  showBottom: false,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              )
            else if (appProvider.currentRecordingPath != null)
              AudioFileWaveforms(
                size: Size(MediaQuery.of(context).size.width, 100.0),
                playerController: _playerController,
                enableSeekGesture: true,
                waveformType: WaveformType.long,
                playerWaveStyle: const PlayerWaveStyle(
                  fixedWaveColor: Colors.white54,
                  liveWaveColor: Colors.blue,
                  spacing: 6,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => appProvider.importFile(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import'),
                ),
                if (!appProvider.isRecording)
                  FloatingActionButton(
                    heroTag: 'recordBtn',
                    onPressed: () => appProvider.startRecording(),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.mic),
                  )
                else
                  FloatingActionButton(
                    heroTag: 'stopRecordBtn',
                    onPressed: () => appProvider.stopRecording(),
                    child: const Icon(Icons.stop),
                  ),
                if (appProvider.currentRecordingPath != null &&
                    !appProvider.isPlaying)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => appProvider
                        .playRecording(appProvider.currentRecordingPath),
                    iconSize: 32,
                  )
                else if (appProvider.isPlaying)
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => appProvider.stopPlayback(),
                    iconSize: 32,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
