import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/elevenlabs_service.dart';
import 'package:voice_changer_app/services/file_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import 'package:voice_changer_app/utils/ad_helper.dart';
import 'package:voice_changer_app/utils/banner_ad_widget.dart';

class CelebrityVoiceScreen extends StatefulWidget {
  const CelebrityVoiceScreen({super.key});

  @override
  State<CelebrityVoiceScreen> createState() => _CelebrityVoiceScreenState();
}

class _CelebrityVoiceScreenState extends State<CelebrityVoiceScreen>
    with TickerProviderStateMixin {
  String? _selectedVoiceId;
  String? _selectedVoiceName;
  String? _convertedAudioPath;
  bool _apiKeyWarningShown = false;

  // Animation controllers
  late AnimationController _backgroundController;

  // Animations
  late Animation<double> _backgroundAnimation;
  final ScrollController _scrollController = ScrollController();
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
    _scrollController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  // Get avatar URL based on character name
  String? _getAvatarUrl(String name) {
    final Map<String, String> avatarUrls = {
      'Rachel':
          'https://plus.unsplash.com/premium_photo-1670884441012-c5cf195c062a?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Clyde':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Roger':
          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Sarah':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=922&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Laura':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=928&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Thomas':
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Charlie':
          'https://images.unsplash.com/photo-1695927621677-ec96e048dce2?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'George':
          'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Callum':
          'https://images.unsplash.com/photo-1633530103946-a0904ff5080f?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'River':
          'https://images.unsplash.com/photo-1734830268394-6c4a1f165af1?q=80&w=1160&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Harry':
          'https://images.unsplash.com/photo-1597082037129-2114faa4db61?q=80&w=1742&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Liam':
          'https://plus.unsplash.com/premium_photo-1726815616472-8ddb1c5ea697?q=80&w=1496&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Alice':
          'https://plus.unsplash.com/premium_photo-1674180320326-0452157f2d75?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Matilda':
          'https://plus.unsplash.com/premium_photo-1689551670902-19b441a6afde?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Will':
          'https://images.unsplash.com/photo-1586584041662-3e9521d8344b?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Jessica':
          'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?q=80&w=1734&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Eric':
          'https://images.unsplash.com/photo-1620144143867-fd1b93a1cb22?q=80&w=1656&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Chris':
          'https://images.unsplash.com/photo-1755140302411-9a7a9f523c1e?q=80&w=1494&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Brian':
          'https://images.unsplash.com/photo-1663575127021-6c01d8bba42c?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Daniel':
          'https://images.unsplash.com/photo-1610611742876-97e4d834d077?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Lily':
          'https://images.unsplash.com/photo-1742783107507-dc8bcd8fc30d?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'Bill':
          'https://images.unsplash.com/photo-1687626795751-b1cd1b9c993c?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    };

    return avatarUrls[name];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_apiKeyWarningShown) {
      final elevenLabsService =
          Provider.of<ElevenLabsService>(context, listen: false);
      if (elevenLabsService.elevenLabsApiKey == 'YOUR_ELEVENLABS_API_KEY') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showApiKeyWarning();
        });
        _apiKeyWarningShown = true;
      }
    }
  }

  void _showApiKeyWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 24),
            ),
            SizedBox(width: 12),
            Text('API Key Required',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To use celebrity voice conversion, you need to set up your ElevenLabs API key.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Update lib/utils/constants.dart with your API key',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text('Got it', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AudioService, ElevenLabsService, FileService>(
      builder: (context, audioService, elevenLabsService, fileService, child) {
        final audioState = audioService.audioState;
        final isRecording = audioState == AudioState.recording;
        final isPlaying = audioState == AudioState.playing;
        final hasRecording = audioService.recordedFilePath != null;

        return Scaffold(
          body: AnimatedBuilder(
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
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with title and subtitle
                          _buildHeader(),
                          const SizedBox(height: 20),
                          const BannerAdWidget(),
                          const SizedBox(height: 20),
                          // Celebrity Grid/Carousel
                          _buildCelebrityGrid(elevenLabsService),
                          const SizedBox(height: 32),

                          // Central Microphone Section
                          _buildMicrophoneSection(audioService, isRecording,
                              isPlaying, hasRecording),
                          const SizedBox(height: 32),

                          // Playback Section (shown after conversion)
                          if (_convertedAudioPath != null)
                            _buildPlaybackSection(
                                audioService, fileService, isPlaying),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.star, color: Colors.white, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Celebrity Voice Magic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Transform into your favorite star!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '🎤 Record • 🌟 Select • ✨ Transform',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrityGrid(ElevenLabsService elevenLabsService) {
    // Only use real ElevenLabs voices
    List<Map<String, dynamic>> allVoices = [];

    // Add real ElevenLabs voices if available
    if (elevenLabsService.voices.isNotEmpty) {
      allVoices.addAll(elevenLabsService.voices.map((voice) => {
            'voice_id': voice['voice_id'],
            'name': voice['name'],
            'avatar_url': _getAvatarUrl(voice['name']),
            'color': Colors
                .primaries[voice['name'].hashCode % Colors.primaries.length],
            'isReal': true,
          }));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.people, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Choose Your Celebrity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (elevenLabsService.isLoading)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading celebrity voices...',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          )
        else if (allVoices.isEmpty)
          Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.voice_over_off,
                    color: Colors.white.withOpacity(0.7),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Celebrity Voices Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check your ElevenLabs API key\nand internet connection',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: allVoices.length,
            itemBuilder: (context, index) {
              final voice = allVoices[index];
              final isSelected = _selectedVoiceId == voice['voice_id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVoiceId = voice['voice_id'];
                    _selectedVoiceName = voice['name'];
                    _convertedAudioPath = null;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [Colors.amber, Colors.orange]
                          : [
                              voice['color'].withOpacity(0.8),
                              voice['color'].withOpacity(0.6),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? Colors.amber.withOpacity(0.5)
                            : voice['color'].withOpacity(0.3),
                        blurRadius: isSelected ? 15 : 8,
                        offset: Offset(0, isSelected ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: ClipOval(
                          child: voice['avatar_url'] != null
                              ? Image.network(
                                  voice['avatar_url'],
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            voice['color'].withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: voice['color'].withOpacity(0.3),
                                      child: Center(
                                        child: Text(
                                          voice['name'][0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: voice['color'].withOpacity(0.3),
                                  child: Center(
                                    child: Text(
                                      voice['name'][0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            voice['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMicrophoneSection(AudioService audioService, bool isRecording,
      bool isPlaying, bool hasRecording) {
    return Column(
      children: [
        // Instructions
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            isRecording
                ? '🎤 Recording your voice...'
                : hasRecording
                    ? '✅ Ready to transform!'
                    : '👆 Tap the mic to start recording',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 24),

        // Microphone Button
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isRecording
                  ? [Colors.red, Colors.red.shade700]
                  : hasRecording
                      ? [Colors.green, Colors.green.shade700]
                      : [Colors.blue, Colors.blue.shade700],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isRecording
                        ? Colors.red
                        : hasRecording
                            ? Colors.green
                            : Colors.blue)
                    .withOpacity(0.6),
                blurRadius: 25,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(70),
              onTap: isRecording
                  ? audioService.stopRecording
                  : audioService.startRecording,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 32),

        // Control buttons
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Play recorded audio button
              Flexible(
                child: _buildControlButton(
                  icon: isPlaying ? Icons.stop : Icons.play_arrow,
                  label: isPlaying ? 'Stop' : 'Play',
                  color: isPlaying ? Colors.orange : Colors.green,
                  onTap: hasRecording && !isRecording
                      ? (isPlaying
                          ? audioService.stopPlayback
                          : () => audioService.startPlayback(
                              filePath: audioService.recordedFilePath!))
                      : null,
                ),
              ),

              SizedBox(width: 16),

              // Transform button
              Flexible(
                child: _buildControlButton(
                    icon: Icons.auto_awesome,
                    label: 'Transform',
                    color: Colors.purple,
                    onTap: () {
                      if (hasRecording &&
                          _selectedVoiceId != null &&
                          !isRecording) {
                          AdHelper.showInterstitialAd();
                         
                        _convertVoice(
                            audioService,
                            Provider.of<ElevenLabsService>(context,
                                listen: false));
                      } 
                    }),
              ),
            ],
          ),
        ),

        if (hasRecording && audioService.recordedFilePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                '📁 ${audioService.recordedFilePath!.split('/').last}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }



  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Container(
      constraints: BoxConstraints(
        minWidth: 80,
        maxWidth: 120,
        minHeight: 60,
        maxHeight: 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? [color, color.withOpacity(0.7)]
              : [Colors.grey.shade600, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackSection(
      AudioService audioService, FileService fileService, bool isPlaying) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Transformed! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'You now sound like $_selectedVoiceName',
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

          SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: isPlaying ? Icons.stop : Icons.play_arrow,
                  label: isPlaying ? 'Stop' : 'Play',
                  color: isPlaying ? Colors.orange : Colors.green,
                  onTap: isPlaying
                      ? audioService.stopPlayback
                      : () => audioService.startPlayback(
                          filePath: _convertedAudioPath!),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: 'Save',
                  color: Colors.blue,
                  onTap: () => _saveConvertedAudio(fileService),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.purple,
                  onTap: () => _shareAudio(),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // File info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack,
                    color: Colors.white.withOpacity(0.7), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _convertedAudioPath!.split('/').last,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      constraints: BoxConstraints(minWidth: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _convertVoice(
      AudioService audioService, ElevenLabsService elevenLabsService) async {
    try {
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('🎭 Transforming your voice into $_selectedVoiceName...'),
            ],
          ),
          backgroundColor: Colors.purple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 10),
        ),
      );

      final convertedPath = await elevenLabsService.convertAudio(
        audioFilePath: audioService.recordedFilePath!,
        voiceId: _selectedVoiceId!,
      );

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        _convertedAudioPath = convertedPath;
      });

      if (_convertedAudioPath != null) {
        // Scroll to bottom after conversion success
        // Delay to ensure UI updated before scrolling
        await Future.delayed(Duration(milliseconds: 200));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Text('🎉 Voice transformation complete!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Auto-play the result
        await audioService.startPlayback(filePath: _convertedAudioPath!);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Text('❌ Transformation failed. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveConvertedAudio(FileService fileService) async {
    if (_convertedAudioPath != null) {
      await fileService.saveAudioFile(
        _convertedAudioPath!,
        fileName:
            'celebrity_${_selectedVoiceName?.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.download_done, color: Colors.white),
              SizedBox(width: 12),
              Text('💾 Audio saved to My Files!'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _shareAudio() async {
    if (_convertedAudioPath != null) {
      await Share.shareXFiles(
        [XFile(_convertedAudioPath!)],
        text:
            '🎭 Check out my celebrity voice transformation! Created with Voice Changer App',
      );
    }
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw animated spotlights
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.3 + math.sin(animationValue * 2 * math.pi + i) * 0.2),
      );

      canvas.drawCircle(
          center, 50 + math.sin(animationValue * math.pi + i) * 20, paint);
      canvas.drawCircle(
          center, 100 + math.cos(animationValue * math.pi + i) * 30, paint);
    }

    // Draw music notes
    final notePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8) +
          math.sin(animationValue * 2 * math.pi + i) * 20;
      final y = size.height * 0.8 + math.cos(animationValue * math.pi + i) * 40;

      canvas.drawCircle(Offset(x, y), 3, notePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
