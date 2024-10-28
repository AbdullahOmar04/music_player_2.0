import 'package:flutter/material.dart';
import 'package:music_player_20/Themes/light_mode.dart';
import 'package:music_player_20/music_provider.dart';
  import 'package:provider/provider.dart'; 
import 'Pages/main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MusicPlayerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: lightmode,
      home: const MainPage(),
    );
  }
}