import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:music_player_20/Pages/music_player_page.dart';
import 'package:music_player_20/items.dart';
import 'package:music_player_20/music_provider.dart';
import 'package:music_player_20/new_song.dart';
import 'package:music_player_20/viewers.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../new_playlist.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

class _MainPage extends State<MainPage> {
  List<CustomPlaylist> _playlist = [];
  List<CustomSong> allSongs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _loadPlaylists();
  }

  void _songAddBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AddSong(onAddItem: _addSongg),
          ],
        ),
      ),
    );
  }

  void _addSongg(CustomSong songItems) async {
    setState(() {
      allSongs.add(songItems);
    });
  }

  void _loadSongs() async {
    final url = Uri.https(
        'musica-app-fed54-default-rtdb.europe-west1.firebasedatabase.app',
        'add-song.json');

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<CustomSong> loadedSongs = [];
    for (final item in listData.entries) {
      loadedSongs.add(
        CustomSong(
            title: item.value['title'],
            artist: item.value['artist'],
            songPath: item.value['songPath'],
            imagePath: item.value['imagePath'],
            id: item.key),
      );
    }
    setState(() {
      allSongs = loadedSongs;
    });
  }

  void _playlistBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[NewPlaylist(onAddItem: _addPlaylist)],
        ),
      ),
    );
  }

  void _addPlaylist(CustomPlaylist playlistItems) async {
    setState(() {
      _playlist.add(playlistItems);
    });
  }

  void _loadPlaylists() async {
    final url = Uri.https(
        'musica-app-fed54-default-rtdb.europe-west1.firebasedatabase.app',
        'add-playlist.json');

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<CustomPlaylist> loadedPlaylists = [];
    for (final item in listData.entries) {
      loadedPlaylists.add(
        CustomPlaylist(
          title: item.value['title'],
          imagePath: item.value['imagePath'],
          id: item.key,
        ),
      );
    }
    setState(() {
      _playlist = loadedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget pLViewer = PlaylistListViewerMainPage(playlistItems: _playlist);
    Widget favSongViewer = FavouriteSongsViewerMainPage(
        songItems: allSongs, onSongTap: _playSong);

    if (_playlist.isEmpty) {
      pLViewer = Container(
        color: Colors.orange[50],
        child: const Center(
          child: Text("You have no playlists! \n          Create one."),
        ),
      );
    }

    if (allSongs.isEmpty) {
      favSongViewer = Container(
        color: Colors.orange[50],
        child: const Center(
          child: Text("You have no Songs! \n         Add one."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Musica"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: const Icon(
                Icons.music_note,
                size: 50,
                color: Colors.brown,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 30),
              child: ListTile(
                title: Text("Home"),
                leading: Icon(Icons.home),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 30),
              child: ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: IconButton(
              onPressed: () {
                _playlistBottomSheet();
              },
              icon: const Icon(Icons.add),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 55),
              child: Text(
                "Your Playlists",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 180,
            child: pLViewer,
          ),
          ListTile(
            leading: IconButton(
              onPressed: () {
                _songAddBottomSheet();
              },
              icon: const Icon(Icons.add),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 75),
              child: Text(
                "All Songs",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 400,
            child: favSongViewer,
          ),
        ],
      ),
    );
  }

  void _playSong(CustomSong song) {
    Provider.of<MusicPlayerProvider>(context, listen: false)
        .setSong(song.songPath);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerPage(song: song),
      ),
    );
  }
}
