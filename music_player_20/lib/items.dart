// ignore: avoid_web_libraries_in_flutter
import 'package:uuid/uuid.dart';

class CustomPlaylist {
  CustomPlaylist({
    required this.title,
    required this.imagePath,
    required this.id,
  }) : idd = const Uuid().v4();

  final String title;
  final String imagePath;
  final String id;

  final String idd;
}

class CustomSong {
  CustomSong({
    this.favourited = false,
    required this.title,
    required this.artist,
    required this.songPath,
    required this.imagePath,
    required this.id,
  }) : idd = const Uuid().v4();

  final String title;
  final String artist;
  final String songPath;
  final String imagePath;
  final String id;
  bool favourited;

  final String idd;
}

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

