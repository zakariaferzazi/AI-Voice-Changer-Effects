import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/services/text_to_speech_service.dart';
import 'dart:math' as math;

import 'package:voice_changer_app/utils/ad_helper.dart';
import 'package:voice_changer_app/utils/banner_ad_widget.dart'; // Import for math.sin and math.cos

// This is a custom painter to create the background pattern
// You'll need to add this class if it's not already defined in your project
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw some dynamic shapes or lines based on animationValue
    for (int i = 0; i < 5; i++) {
      double offset = animationValue * 2 * math.pi + i * (math.pi / 2);
      double x = size.width * (0.5 + 0.4 * math.sin(offset));
      double y = size.height * (0.5 + 0.4 * math.cos(offset));
      double radius = 50 + 40 * math.sin(offset + math.pi / 4);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Add some rotating lines
    for (int i = 0; i < 3; i++) {
      double rotation = animationValue * 2 * math.pi + i * (math.pi / 3);
      double lineLength = size.width * 0.6;
      double lineThickness = 2;

      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(rotation);
      canvas.drawLine(
        Offset(-lineLength / 2, 0),
        Offset(lineLength / 2, 0),
        paint..strokeWidth = lineThickness,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as BackgroundPatternPainter).animationValue !=
        animationValue;
  }
}

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  // Animation controllers and animations for the background
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    AdHelper.loadInterstialAd();
  }

  void _initAnimations() {
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
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Text to Speech',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // The AnimatedBuilder now controls the entire body, ensuring
      // the background is full-screen.
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
              // The gradient container now fills the entire screen
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                        Colors.purple.shade900,
                        Colors.indigo.shade900,
                        math.sin(_backgroundAnimation.value * 2 * math.pi) *
                                0.3 +
                            0.7)!,
                    Color.lerp(
                        Colors.blue.shade800,
                        Colors.purple.shade800,
                        math.cos(_backgroundAnimation.value * 2 * math.pi) *
                                0.3 +
                            0.7)!,
                    Color.lerp(
                        Colors.indigo.shade900,
                        Colors.blue.shade900,
                        math.sin(_backgroundAnimation.value * 3 * math.pi) *
                                0.3 +
                            0.7)!,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: BackgroundPatternPainter(_backgroundAnimation.value),
                child: SafeArea(
                  // SingleChildScrollView is now inside the gradient container
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Consumer<TextToSpeechService>(
                      builder: (context, ttsService, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            // Description
                            const Text(
                              'Enter your text below and tap "Speak" to hear it with various effects.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Text input field with updated styling
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _textController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Type something to speak...',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                maxLines: 6,
                                minLines: 3,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Speak/Stop button
                            ElevatedButton.icon(
                              onPressed: () {
                                
                                if (ttsService.isSpeaking){
                                  ttsService.stop;
                                }else{
                                  AdHelper.showInterstitialAd();
                                  ttsService.speak(_textController.text);
                                  
                                } 
                                
                                    
                                        
                              },
                              icon: Icon(
                                ttsService.isSpeaking
                                    ? Icons.stop
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                              label: Text(
                                ttsService.isSpeaking
                                    ? 'Stop Speaking'
                                    : 'Speak Text',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ttsService.isSpeaking
                                    ? Colors.redAccent.shade400
                                    : Colors.greenAccent.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                elevation: 8,
                                shadowColor: ttsService.isSpeaking
                                    ? Colors.redAccent.withOpacity(0.4)
                                    : Colors.greenAccent.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const BannerAdWidget(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
