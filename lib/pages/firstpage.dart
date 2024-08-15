import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class xylop extends StatefulWidget {
  const xylop({super.key});

  @override
  State<xylop> createState() => _xylopState();
}

class _xylopState extends State<xylop> {
  final player = AudioPlayer();
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> playSound(int a) async {
    try {
      await player.setAsset('assets/music/note$a.wav');
      player.play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("firstpage"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: 100,
                color: Colors.red,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      playSound(1);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      playSound(2);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.yellow,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      playSound(3);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.orange,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      playSound(4);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 100,
                color: Colors.green,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      playSound(5);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
