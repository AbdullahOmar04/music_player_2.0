import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'items.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<CustomSong> _songs = [];
  String? _currentSongPath;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<CustomSong> get songs => _songs;
  String? get currentSongPath => _currentSongPath;

  Future<void> setSong(String songPath) async {
    _currentSongPath = songPath;
    await _audioPlayer.setFilePath(songPath);
    notifyListeners();
  }

  void addSong(CustomSong song) {
    _songs.add(song);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
