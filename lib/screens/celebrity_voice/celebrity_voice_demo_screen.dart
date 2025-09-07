import 'package:flutter/material.dart';
import 'dart:math';

class CelebrityVoiceDemoScreen extends StatefulWidget {
  const CelebrityVoiceDemoScreen({super.key});

  @override
  State<CelebrityVoiceDemoScreen> createState() =>
      _CelebrityVoiceDemoScreenState();
}

class _CelebrityVoiceDemoScreenState extends State<CelebrityVoiceDemoScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _selectedVoice;
  bool _isConverting = false;
  bool _conversionComplete = false;

  final List<Map<String, String>> _demoVoices = [
    {'id': '1', 'name': 'Morgan Freeman'},
    {'id': '2', 'name': 'Scarlett Johansson'},
    {'id': '3', 'name': 'Robert Downey Jr.'},
    {'id': '4', 'name': 'Emma Stone'},
    {'id': '5', 'name': 'Benedict Cumberbatch'},
    {'id': '6', 'name': 'Jennifer Lawrence'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
              Colors.amber.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Demo Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Demo Mode - Experience the UI without API keys',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.blue),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Header
                _buildHeader(),
                const SizedBox(height: 30),

                // Recording Section
                _buildRecordingSection(),
                const SizedBox(height: 30),

                // Voice Selection Section
                _buildVoiceSelectionSection(),
                const SizedBox(height: 30),

                // Conversion Section
                _buildConversionSection(),
                const SizedBox(height: 20),

                // Result Section
                if (_conversionComplete) _buildResultSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Celebrity Voice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Powered by Advanced AI Technology',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Turn your voice into that of a famous celebrity! With advanced AI technology, you can sound like a star — instantly and effortlessly.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.mic_rounded, color: Colors.deepPurple, size: 24),
              SizedBox(width: 12),
              Text(
                'Step 1: Record Your Voice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Audio Visualization
          Container(
            height: 80,
            child: _isRecording
                ? AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: AudioWavePainter(
                          amplitude:
                              0.7 + (sin(_waveAnimation.value * 2 * pi) * 0.3),
                          wavePhase: _waveAnimation.value,
                        ),
                        size: Size.infinite,
                      );
                    },
                  )
                : Center(
                    child: Text(
                      _isRecording
                          ? 'Recording in progress...'
                          : 'Tap the microphone to start recording',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),

          SizedBox(height: 20),

          // Recording Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Record Button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isRecording
                              ? [Colors.red, Colors.red.shade700]
                              : [Colors.blue, Colors.blue.shade700],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.blue)
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            setState(() {
                              _isRecording = !_isRecording;
                              if (!_isRecording) {
                                // Simulate recording completion
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Demo: Recording completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          },
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Play Button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isPlaying
                        ? [Colors.orange, Colors.orange.shade700]
                        : [Colors.green, Colors.green.shade700],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? Colors.orange : Colors.green)
                          .withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });

                      if (_isPlaying) {
                        // Auto-stop after 3 seconds
                        Future.delayed(Duration(seconds: 3), () {
                          if (mounted) {
                            setState(() {
                              _isPlaying = false;
                            });
                          }
                        });
                      }
                    },
                    child: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (!_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Demo Recording: sample_voice_recording.aac',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person_rounded, color: Colors.deepPurple, size: 24),
              SizedBox(width: 12),
              Text(
                'Step 2: Choose Celebrity Voice',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Row(
                  children: [
                    Icon(Icons.stars, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      'Select a Celebrity Voice',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                value: _selectedVoice,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVoice = newValue;
                    _conversionComplete = false; // Reset result
                  });
                },
                items: _demoVoices.map<DropdownMenuItem<String>>((voice) {
                  return DropdownMenuItem<String>(
                    value: voice['id'],
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          voice['name']!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_selectedVoice != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Text(
                  'Selected: ${_demoVoices.firstWhere((v) => v['id'] == _selectedVoice)['name']}',
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversionSection() {
    final canConvert =
        _selectedVoice != null && !_isRecording && !_isConverting;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 24),
              SizedBox(width: 12),
              Text(
                'Step 3: AI Voice Conversion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (_isConverting)
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Converting your voice...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  'This may take a few moments',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: canConvert ? _simulateConversion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canConvert ? Colors.deepPurple : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: canConvert ? 8 : 0,
                  shadowColor: Colors.deepPurple.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.transform, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Transform Voice with AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16),
          Text(
            canConvert
                ? 'Ready to transform your voice!'
                : 'Complete steps 1 & 2 to enable conversion',
            style: TextStyle(
              color: canConvert ? Colors.green : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final selectedVoiceName =
        _demoVoices.firstWhere((v) => v['id'] == _selectedVoice)['name'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Conversion Complete!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Your voice has been transformed into $selectedVoiceName!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'demo_${selectedVoiceName?.replaceAll(' ', '_').toLowerCase()}_conversion.mp3',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demo: Playing converted audio...'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demo: Audio saved to My Files!'),
                        backgroundColor: Colors.deepPurple,
                      ),
                    );
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _simulateConversion() async {
    setState(() {
      _isConverting = true;
    });

    // Simulate AI processing time
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isConverting = false;
      _conversionComplete = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Demo: Voice converted successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// Custom painter for audio wave visualization
class AudioWavePainter extends CustomPainter {
  final double amplitude;
  final double wavePhase;

  AudioWavePainter({required this.amplitude, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x <= size.width; x += 2) {
      final normalizedX = x / size.width;
      final wave1 =
          sin((normalizedX * 4 * pi) + (wavePhase * 2 * pi)) * amplitude * 20;
      final wave2 =
          sin((normalizedX * 6 * pi) + (wavePhase * 3 * pi)) * amplitude * 10;
      final y = centerY + wave1 + wave2;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw additional wave lines
    paint.color = Colors.deepPurple.withOpacity(0.3);
    paint.strokeWidth = 2;

    final path2 = Path();
    for (double x = 0; x <= size.width; x += 3) {
      final normalizedX = x / size.width;
      final wave =
          sin((normalizedX * 8 * pi) + (wavePhase * 4 * pi)) * amplitude * 15;
      final y = centerY + wave;

      if (x == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(AudioWavePainter oldDelegate) {
    return amplitude != oldDelegate.amplitude ||
        wavePhase != oldDelegate.wavePhase;
  }
}
