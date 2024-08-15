import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

//  Global variable
List<PlatformFile>?
    Selectedfiles; // this holds the list of files selected by the user

List<PlatformFile> mp3s = [];

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
      setState(() {
        //  since we use SetState()  we need to write this function inside "State<thirdpg>" Since it extends the state class
        Selectedfiles = result.files;

        for (var file in Selectedfiles!) {
          if (!mp3s.any((element) => element.name == file.name)) {
            mp3s.add(file);
          } else {
            print("contains file");
          }
        }
      });
      // selectedfiles are defines in top of page
    }
  }

  Future<File> saveflieperma(PlatformFile file) async {
    final appstorage = await getApplicationDocumentsDirectory();
    final addedfile = File('${appstorage}/${file.name}');

    return File(file.path!).copy(addedfile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("third page"),
      ),
      body: Column(children: [
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
                  itemCount: mp3s!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var file = mp3s![index];
                    return ListTile(
                      tileColor: Colors.grey.shade600,
                      title: Text("Name: ${file.name}"),
                      subtitle: Text("Size: ${file.size} bytes"),
                      onTap: () {},
                    );
                  },
                ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [],
              )
            ],
          ),
        )
      ]),
    );
  }
}
