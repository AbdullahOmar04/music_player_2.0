import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player_20/Themes/neu_box.dart';
import 'package:music_player_20/items.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class MusicPlayerPage extends StatefulWidget {
  final CustomSong song;

  const MusicPlayerPage({super.key, required this.song});

  @override
  State<StatefulWidget> createState() {
    return _MusicPlayerPage();
  }
}

class _MusicPlayerPage extends State<MusicPlayerPage> {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  


  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final url = Uri.https(
        'musica-app-fed54-default-rtdb.europe-west1.firebasedatabase.app',
        'add-song.json');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Assuming the data is a list of song details
        final List<dynamic> songsData = json.decode(response.body);
        List<AudioSource> sources = songsData.map((songData) {
          final songUrl = songData['url'];
          return AudioSource.uri(Uri.parse(songUrl));
        }).toList();

        _playlist = ConcatenatingAudioSource(children: sources);
        await _audioPlayer.setAudioSource(_playlist);
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (e) {
      print('Error loading playlist: $e');
    }
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.song.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: NeuBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.song.imagePath),
                ),
              ),
            ),
          ),
          Text.rich(
            TextSpan(
              text: "Artist: ",
              style: const TextStyle(fontSize: 20),
              children: <TextSpan>[
                TextSpan(
                  text: widget.song.artist,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ProgressBar(
                  barHeight: 8,
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  onSeek: _audioPlayer.seek,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          NeuBoxCircle(
            child: Controls(audioPlayer: _audioPlayer),
          ),
        ],
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key, required this.audioPlayer});

  final AudioPlayer audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (!(playing ?? false)) {
          return Column(
            children: [
              IconButton(
                onPressed: audioPlayer.play,
                iconSize: 50,
                color: Colors.white,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            onPressed: audioPlayer.pause,
            iconSize: 50,
            color: Colors.white,
            icon: const Icon(Icons.pause_rounded),
          );
        }
        return const Icon(
          Icons.play_arrow_rounded,
          size: 50,
          color: Colors.white,
        );
      },
    );
  }
}
