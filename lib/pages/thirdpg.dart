import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global variables
List<PlatformFile>? Selectedfiles;
List<File> mp3s = [];
final player = AudioPlayer();
int i = 0;
List<String>? paths;
int currentindxplayer = 0;

class Thirdpg extends StatefulWidget {
  const Thirdpg({super.key});

  @override
  State<Thirdpg> createState() => _ThirdpgState();
}

class _ThirdpgState extends State<Thirdpg> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Future<void> pickflieMulti() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.audio);

    if (result != null) {
      Selectedfiles = result.files;
      for (var file in Selectedfiles!) {
        await saveflieperma(file);
      }
      await fetchSavedFiles();
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
    mp3s.clear();
    for (FileSystemEntity entity in files) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        mp3s.add(entity);
        paths!.add(entity.path);
      }
    }
    await prefs.setStringList('mp3List', paths!);
  }

  Future<void> loadsavedFiles() async {
    fetchSavedFiles();
    setState(() {});
    SharedPreferences prefer = await SharedPreferences.getInstance();
    setState(() {});
    paths = prefer.getStringList('mp3List');
    if (paths != null) {
      mp3s.clear();
      for (String path in paths!) {
        mp3s.add(File(path));
      }
    }
    fetchSavedFiles();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadsavedFiles();
    // the below functions set the state of the slider
    player.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
    player.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("third page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextButton(
              onPressed: () {
                pickflieMulti();
              },
              child: Text("click button to choose file"),
            ),
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
                          currentindxplayer =
                              index; // TODO: set skip button , write its function
                          player.setAudioSource(AudioSource.file(file.path));
                        },
                      );
                    },
                  ),
          ),
          Column(
            children: [
              // adds the slider function
              Slider(
                min: 0.0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds
                    .toDouble()
                    .clamp(0.0, _duration.inSeconds.toDouble()),
                onChanged: (value) async {
                  await player.seek(Duration(seconds: value.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_position.toString().split('.').first),
                  Text(_duration.toString().split('.').first),
                ],
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.max,
                      buttonPadding: EdgeInsets.all(10),
                      buttonAlignedDropdown: Platform.isAndroid,
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
                              player.seek(
                                  Duration(seconds: _position.inSeconds + 10));
                            },
                            icon: Icon(Icons.fast_forward)),
                        IconButton(
                            onPressed: () {
                              player.seek(
                                  Duration(seconds: _position.inSeconds - 10));
                            },
                            icon: Icon(Icons.fast_rewind)),
                        IconButton(
                            onPressed: () {
                              void skip(int i) {
                                if (currentindxplayer < mp3s.length) {
                                  // write its functionality
                                  currentindxplayer = i + 1;
                                  if (currentindxplayer == mp3s.length) {
                                    currentindxplayer = 0;
                                  }
                                  player.setAudioSource(AudioSource.file(
                                      mp3s[currentindxplayer].path));
                                } else {
                                  currentindxplayer = 0;
                                  player.setAudioSource(AudioSource.file(
                                      mp3s[currentindxplayer].path));
                                }
                              }

                              skip(currentindxplayer);
                            },
                            icon: Icon(Icons.skip_next)),
                        IconButton(
                            onPressed: () {
                              void preskip(int i) {
                                if (i - 1 >= 0) {
                                  // write its functionality
                                  player.setAudioSource(
                                      AudioSource.file(mp3s[i - 1].path));

                                  currentindxplayer = i - 1;
                                } else {
                                  currentindxplayer = mp3s.length - 2;
                                  player.setAudioSource(AudioSource.file(
                                      mp3s[currentindxplayer].path));
                                }
                              }

                              preskip(currentindxplayer);
                            },
                            icon: Icon(Icons.skip_previous_rounded)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
