import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voice_changer_app/screens/SplachScreen.dart';
import 'package:voice_changer_app/screens/celebrity_voice/celebrity_voice_screen.dart';
import 'package:voice_changer_app/screens/my_files/my_files_screen.dart';
import 'package:voice_changer_app/screens/text_to_speech/text_to_speech_screen.dart';
import 'package:voice_changer_app/services/audio_service.dart';
import 'package:voice_changer_app/services/elevenlabs_service.dart';
import 'package:voice_changer_app/services/text_to_speech_service.dart';
import 'package:voice_changer_app/services/file_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // Initialize the AdMob SDK
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
        home: const SplashScreen(),
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

  void shareAppLink() {
    Share.share(
      'Check out this app: https://play.google.com/store/apps/details?id=com.ai.voice.changer',
      subject: 'AI Voice Changer App',
    );
  }

  Future<void> launchAppLink() async {
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.ai.voice.changer');
    await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // This makes body extend behind AppBar
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        toolbarHeight: 70,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.15), // Semi-transparent background
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AI/Magic Icon Container
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[400]!,
                      Colors.blue[400]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Voice Changer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          // Search Icon
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.star,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Review',
              onPressed: () {
                launchAppLink();
              },
            ),
          ),
          // Share Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Share',
              onPressed: () {
                shareAppLink();
              },
            ),
          ),
        ],
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
          TextToSpeechScreen(),
          MyFilesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:
              Colors.white, // Set background color of the BottomNavigationBar
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Circular top-left corner
            topRight: Radius.circular(30), // Circular top-right corner
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
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
                icon: Icon(Icons.speaker_notes_rounded),
                label: 'TTS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_copy_rounded),
                label: 'My Files',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
