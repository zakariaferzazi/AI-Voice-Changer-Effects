import 'package:flutter/material.dart';
import 'package:voice_changer/screens/celebrity_voice_screen.dart';
import 'package:voice_changer/screens/my_files_screen.dart';
import 'package:voice_changer/screens/tts_screen.dart';
import 'package:voice_changer/screens/voice_effects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CelebrityVoiceScreen(),
    VoiceEffectsScreen(),
    TextToSpeechScreen(),
    MyFilesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Changer'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Celebrity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waves),
            label: 'Effects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Text-to-Speech',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'My Files',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
