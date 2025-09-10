import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/file_service.dart';
import 'dart:math' as math;

import 'package:voice_changer_app/utils/banner_ad_widget.dart';

// -- Custom Painter Copied From CelebrityVoiceScreen --
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Spotlights
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.3 + math.sin(animationValue * 2 * math.pi + i) * 0.2),
      );
      canvas.drawCircle(center, 50 + math.sin(animationValue * math.pi + i) * 20, paint);
      canvas.drawCircle(center, 100 + math.cos(animationValue * math.pi + i) * 30, paint);
    }

    // Music notes
    final notePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8) + math.sin(animationValue * 2 * math.pi + i) * 20;
      final y = size.height * 0.8 + math.cos(animationValue * math.pi + i) * 40;
      canvas.drawCircle(Offset(x, y), 3, notePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => animationValue != oldDelegate.animationValue;
}

// -- MyFilesScreen StatefulWidget with Animation --
class MyFilesScreen extends StatefulWidget {
  const MyFilesScreen({super.key});

  @override
  State<MyFilesScreen> createState() => _MyFilesScreenState();
}

class _MyFilesScreenState extends State<MyFilesScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                    Colors.purple.shade900,
                    Colors.indigo.shade900,
                    math.sin(_backgroundAnimation.value * 2 * math.pi) * 0.3 + 0.7)!,
                Color.lerp(
                    Colors.blue.shade800,
                    Colors.purple.shade800,
                    math.cos(_backgroundAnimation.value * 2 * math.pi) * 0.3 + 0.7)!,
                Color.lerp(
                    Colors.indigo.shade900,
                    Colors.blue.shade900,
                    math.sin(_backgroundAnimation.value * 3 * math.pi) * 0.3 + 0.7)!,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPatternPainter(_backgroundAnimation.value),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                
                title: const BannerAdWidget(),
              ),
              body: Consumer2<FileService, AudioService>(
                builder: (context, fileService, audioService, child) {
                  if (fileService.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (fileService.savedAudioFiles.isEmpty) {
                    return const Center(child: Text('No saved audio files.'));
                  } else {
                    return ListView.builder(
                      itemCount: fileService.savedAudioFiles.length,
                      itemBuilder: (context, index) {
                        final audioFile = fileService.savedAudioFiles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(audioFile.name),
                            subtitle: Text(audioFile.createdAt.toLocal().toString().split('.')[0]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: audioService.audioState == AudioState.playing &&
                                          audioService.recordedFilePath == audioFile.path
                                      ? const Icon(Icons.stop)
                                      : const Icon(Icons.play_arrow),
                                  onPressed: () {
                                    if (audioService.audioState == AudioState.playing &&
                                        audioService.recordedFilePath == audioFile.path) {
                                      audioService.stopPlayback();
                                    } else {
                                      audioService.startPlayback(filePath: audioFile.path);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () async {
                                    await Share.shareXFiles(
                                      [XFile(audioFile.path)],
                                      text: 'Check out this audio from Voice Changer App!',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => fileService.deleteAudioFile(audioFile.path),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
