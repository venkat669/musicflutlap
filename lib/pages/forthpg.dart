import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';

class Mp3Scanner extends StatefulWidget {
  @override
  _Mp3ScannerState createState() => _Mp3ScannerState();
}

class _Mp3ScannerState extends State<Mp3Scanner> {
  List<File> mp3Files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    requestPermissionsAndScan();
  }

  Future<void> requestPermissionsAndScan() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      mp3Files = await getMp3Files();
    } else {
      // Handle permission denied
      print("Permission denied");
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<File>> getMp3Files() async {
    List<File> mp3Files = [];
    Directory dir = Directory('/storage/emulated/0'); // Starting directory
    print("Scanning directory: ${dir.path}");

    try {
      await for (FileSystemEntity entity
          in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          print("Found MP3: ${entity.path}");
          mp3Files.add(entity);
        }
      }
    } catch (e) {
      print("Error scanning files: $e");
    }

    return mp3Files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MP3 Files"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : mp3Files.isEmpty
              ? Center(child: Text("No MP3 files found"))
              : ListView.builder(
                  itemCount: mp3Files.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(mp3Files[index].path.split('/').last),
                      subtitle: Text(mp3Files[index].path),
                    );
                  },
                ),
    );
  }
}
