import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/file_service.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FileService, AudioService>(
      builder: (context, fileService, audioService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Files'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => print("ndd"),
              ),
              IconButton(
                icon: const Icon(Icons.add_to_photos),
                onPressed: () => fileService.importAudioFile(),
              ),
            ],
          ),
          body: fileService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : fileService.savedAudioFiles.isEmpty
                  ? const Center(child: Text('No saved audio files.'))
                  : ListView.builder(
                      itemCount: fileService.savedAudioFiles.length,
                      itemBuilder: (context, index) {
                        final audioFile = fileService.savedAudioFiles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(audioFile.name),
                            subtitle: Text(audioFile.createdAt
                                .toLocal()
                                .toString()
                                .split('.')[0]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: audioService.audioState ==
                                              AudioState.playing &&
                                          audioService.recordedFilePath ==
                                              audioFile.path
                                      ? const Icon(Icons.stop)
                                      : const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    if (audioService.audioState ==
                                            AudioState.playing &&
                                        audioService.recordedFilePath ==
                                            audioFile.path) {
                                      audioService.stopPlayback();
                                    } else {
                                      audioService.startPlayback(
                                          filePath: audioFile.path);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () async {
                                    await Share.shareXFiles(
                                        [XFile(audioFile.path)],
                                        text:
                                            'Check out this audio from Voice Changer App!');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => fileService
                                      .deleteAudioFile(audioFile.path),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
