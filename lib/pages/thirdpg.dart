import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

//  Global variable
List<PlatformFile>?
    Selectedfiles; // this holds the list of files selected by the user

List<File> mp3s = [];

final player = AudioPlayer();
// final playlist = ConcatenatingAudioSource(
//   children: [
//     for (File file in mp3s) AudioSource.file(file.path),
//   ],
// );
int i = 0;
List<String>? paths;

class Thirdpg extends StatefulWidget {
  const Thirdpg({super.key});

  @override
  State<Thirdpg> createState() => _ThirdpgState();
}

class _ThirdpgState extends State<Thirdpg> {
  Future<void> pickflieMulti() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.audio);

    if (result != null) {
      // Handle file saving and fetching asynchronously
      Selectedfiles = result.files;

      for (var file in Selectedfiles!) {
        final newfile = await saveflieperma(file); // Save the file permanently
      }

      // Fetch the saved files from the directory
      await fetchSavedFiles();

      // Update the UI
      setState(() {});
    }
  }

  Future<File> saveflieperma(PlatformFile file) async {
    final appstorage = await getApplicationDocumentsDirectory();
    final addedfile = File('${appstorage.path}/${file.name}');

    return File(file.path!).copy(addedfile.path);
  }

  Future<void> fetchSavedFiles() async {
    Directory appStorage = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = appStorage.listSync();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    paths = [];

    mp3s.clear(); // Clear previous files

    for (FileSystemEntity entity in files) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        mp3s.add(entity);
        paths!.add(entity.path);
      }
    }
    // Save the paths to SharedPreferences
    await prefs.setStringList('mp3List', paths!);
  }

  Future<void> loadsavedFiles() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    paths = [];

    paths = prefer.getStringList('mp3List');
    if (paths != null) {
      mp3s.clear();
      for (String path in paths!) {
        mp3s.add(File(path));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadsavedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("third page"),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: EdgeInsets.all(10),
          child: TextButton(
              onPressed: () {
                pickflieMulti();
              },
              child: Text("click button to choose file")),
        ),
        Expanded(
          child: Selectedfiles == null
              ? Center(child: Text("No files selected"))
              : ListView.builder(
                  itemCount: mp3s.length,
                  itemBuilder: (BuildContext context, int index) {
                    var file = mp3s[index];
                    return ListTile(
                      tileColor: Colors.grey.shade600,
                      title: Text("Name: ${file.path.split('/').last}"),
                      subtitle: Column(
                        children: [
                          Text("Path: ${file.path}"),
                          Text("size: ${file.length()}"),
                        ],
                      ),
                      onTap: () {
                        player.setAudioSource(AudioSource.file(file.path));
                      },
                    );
                  },
                ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  ButtonBar(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (i % 2 == 0) {
                            player.play();
                            i++;
                          } else {
                            i = 0;
                            player.pause();
                          }
                        },
                        icon: Icon(Icons.play_arrow_rounded),
                      ),
                      IconButton(
                          onPressed: () {
                            player.seek(Duration(seconds: 10));
                          },
                          icon: Icon(Icons.fast_forward)),
                      IconButton(
                          onPressed: () {
                            player.seek(Duration(seconds: -10));
                          },
                          icon: Icon(Icons.fast_rewind)),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ]),
    );
  }
}
