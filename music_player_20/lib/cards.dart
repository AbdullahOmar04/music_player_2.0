import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player_20/Pages/music_player_page.dart';
import 'package:music_player_20/items.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard(this.playlistItems, {super.key});
  final CustomPlaylist playlistItems;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 2 / 2,
                    child: Image.file(
                      File(playlistItems.imagePath),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  playlistItems.title,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SongCard extends StatelessWidget {
  const SongCard(this.songitem, {super.key});

  final CustomSong songitem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: ListTile(
          tileColor: Theme.of(context).colorScheme.primary,
          leading: AspectRatio(
            aspectRatio: 1/1,
            child: Image.file(
              File(songitem.imagePath),
            ),
          ),
          trailing: InkWell(
            onTap: () {
              songitem.favourited = true;
            },
            child: songitem.favourited == false
                ? const Icon(Icons.favorite_border)
                : const Icon(Icons.favorite),
          ),
          title:
              Text(songitem.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            songitem.artist,
            style: const TextStyle(color: Colors.white70),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              width: 2,
              color: Colors.brown.shade700,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicPlayerPage(song: songitem),
              ),
            );
          },
        ),
      ),
    );
  }
}
