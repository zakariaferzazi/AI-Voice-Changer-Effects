import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer_app/screens/celebrity_voice/celebrity_voice_screen.dart';
import 'package:voice_changer_app/screens/my_files/my_files_screen.dart';
import 'package:voice_changer_app/screens/text_to_speech/text_to_speech_screen.dart';
import 'package:voice_changer_app/screens/voice_effects/voice_effects_screen.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/elevenlabs_service.dart';
import 'package:voice_changer_app/services/text_to_speech_service.dart';
import 'package:voice_changer_app/services/voice_effects_service.dart';
import 'package:voice_changer_app/services/file_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => ElevenLabsService()),
        ChangeNotifierProvider(create: (_) => VoiceEffectsService()),
        ChangeNotifierProvider(create: (_) => TextToSpeechService()),
        ChangeNotifierProvider(create: (_) => FileService()),
      ],
      child: MaterialApp(
        title: 'Voice Changer App',
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
              .copyWith(secondary: Colors.amberAccent),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 8,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.amberAccent,
            foregroundColor: Colors.deepPurple,
            extendedTextStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // cardTheme: CardTheme(
          //   elevation: 4,
          //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //   shape:
          //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.grey[700]),
            hintStyle: TextStyle(color: Colors.grey[500]),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Voice Changer – AI Celebrity Voice & Text-to-Speech'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          CelebrityVoiceScreen(),
          VoiceEffectsScreen(),
          TextToSpeechScreen(),
          MyFilesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_rounded),
            label: 'Celebrity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.audiotrack_rounded),
            label: 'Effects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speaker_notes_rounded),
            label: 'TTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_rounded),
            label: 'My Files',
          ),
        ],
      ),
    );
  }
}
