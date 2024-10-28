import 'package:flutter/material.dart';
import 'package:music_player_20/cards.dart';
import 'package:music_player_20/items.dart';

class PlaylistListViewerMainPage extends StatelessWidget {
  const PlaylistListViewerMainPage({super.key, required this.playlistItems});

  final List<CustomPlaylist> playlistItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: playlistItems.length,
        itemBuilder: (context, index) => PlaylistCard(
          playlistItems[index],
        ),
      ),
    );
  }
}

class FavouriteSongsViewerMainPage extends StatelessWidget {
  const FavouriteSongsViewerMainPage(
      {required this.songItems, super.key, required this.onSongTap});

  final List<CustomSong> songItems;
  final void Function(CustomSong song) onSongTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: ListView.builder(
        itemCount: songItems.length,
        itemBuilder: (context, index) => SongCard(
          songItems[index],
        ),
      ),
    );
  }
}
