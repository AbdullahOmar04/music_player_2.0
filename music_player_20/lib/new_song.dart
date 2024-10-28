// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:music_player_20/items.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class AddSong extends StatefulWidget {
  const AddSong({super.key, required this.onAddItem});

  final void Function(CustomSong songItems) onAddItem;

  @override
  State<StatefulWidget> createState() {
    return _AddSong();
  }
}

final id = const Uuid().v4();

class _AddSong extends State<AddSong> {
  final Audiotagger _tagger = Audiotagger();
  String? _filePath;
  Tag? _tag;

  File? selectedImage;

  void saveSong() async {
    
    final String imagePath = await _saveImage(File(selectedImage!.path), id);

    final url = Uri.https(
        'musica-app-fed54-default-rtdb.europe-west1.firebasedatabase.app',
        'add-song.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {
          'title': "${_tag!.title}",
          'artist': "${_tag!.artist}",
          'songPath': _filePath!,
          'imagePath': imagePath,
        },
      ),
    );

    final Map<String, dynamic> resData = json.decode(response.body);

    print(response.body);
    print(response.statusCode);

    selectedImage = null;
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(
      CustomSong(
          id: resData['name'],
          title: "${_tag!.title}",
          artist: "${_tag!.artist}",
          songPath: _filePath!,
          imagePath: imagePath),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });
    }
  }

  Future<String> _saveImage(File image, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$id.png';
    await image.copy(path);
    return path;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.single.path!;
      });
      await _fetchMetadata();
    }
  }

  Future<void> _fetchMetadata() async {
    Tag? tag = await _tagger.readTags(path: _filePath!);
    setState(() {
      _tag = tag!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.fromLTRB(15, 50, 16, 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _pickImageFromGallery();
            },
            child: selectedImage != null
                ? AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.file(
                      selectedImage!,
                    ),
                  )
                : Image.asset(
                    "assets/images/Add_Image.png",
                    scale: 3,
                  ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.brown),
            ),
            onPressed: _pickFile,
            child: const Text(
              'Add Song',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),
          // ignore: unnecessary_null_comparison
          _tag != null
              ? Column(
                  children: [
                    Text("Title: ${_tag!.title ?? 'Unknown'}"),
                    Text("Artist: ${_tag!.artist ?? 'Unknown'}"),
                    Text("Album: ${_tag!.album ?? 'Unknown'}"),
                    TextButton(
                      onPressed: saveSong,
                      child: const Text('Save'),
                    ),
                  ],
                )
              : const Text(""),
        ],
      ),
    );
  }
}
