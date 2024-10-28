import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'items.dart';

class NewPlaylist extends StatefulWidget {
  const NewPlaylist({super.key, required this.onAddItem});

  final void Function(CustomPlaylist playlistItems) onAddItem;

  @override
  State<StatefulWidget> createState() {
    return _NewPlaylist();
  }
}

final _titleController = TextEditingController();

File? selectedImage;

class _NewPlaylist extends State<NewPlaylist> {
  Future submitForm() async {
    if (_titleController.text.trim().isEmpty || selectedImage == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid"),
          content: const Text("Enter valid inputs..."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text("Okay"),
            ),
          ],
        ),
      );
      return;
    }

    final id = const Uuid().v4();
    final String imagePath = await _saveImage(File(selectedImage!.path), id);

    final url = Uri.https(
        'musica-app-fed54-default-rtdb.europe-west1.firebasedatabase.app',
        'add-playlist.json');
    final response = await http.post(
      url,
      headers: {'Content-Typee': 'application/json'},
      body: json.encode(
        {
          'title': _titleController.text,
          'imagePath': imagePath,
        },
      ),
    );

    final Map<String, dynamic> resData = json.decode(response.body);

    print(response.body);
    print(response.statusCode);

    /*setState(() {
      widget.onAddItem(CustomPlaylist(
          title: _titleController.text, imagePath: imagePath, imageID: id));
    });*/
    
    _titleController.clear();
    selectedImage = null;
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(
      CustomPlaylist(
        id: resData['name'],
        title: _titleController.text,
        imagePath: imagePath,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.fromLTRB(15, 50, 16, 16),
      child: Column(
        children: [
          const Text(
            "Add Image",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 4),
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
          TextField(
            controller: _titleController,
            maxLength: 20,
            decoration: InputDecoration(
              label: Text(
                "Title*",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 20),
              ),
              filled: true,
              fillColor: Colors.amber[50],
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.brown, width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 200),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                ),
                onPressed: () {
                  submitForm();
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
