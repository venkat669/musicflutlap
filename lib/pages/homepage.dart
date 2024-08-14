import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  //  AudioPlayer _audioPlayer;
  // @override
  // void initState(){
  //   super.initState();
  //   _audioPlayer = AudioPlayer();
  // }

  final player = AudioPlayer();
  int cnt = 0;

  final playlist = ConcatenatingAudioSource(
    children: [
      AudioSource.uri(Uri.parse(
          "https://archive.org/download/IGM-V7/IGM%20-%20Vol.%207/25%20Diablo%20-%20Tristram%20%28Blizzard%29.mp3")),
      AudioSource.uri(Uri.parse(
          "https://archive.org/download/IGM-V7/IGM%20-%20Vol.%207/25%20Diablo%20-%20Tristram%20%28Blizzard%29.mp3")),
      AudioSource.uri(Uri.parse(
          "https://archive.org/download/IGM-V7/IGM%20-%20Vol.%207/25%20Diablo%20-%20Tristram%20%28Blizzard%29.mp3")),
    ],
  );

  void initState() {
    super.initState();
    setupPlayer(); //  this line can be replaced by :  player.setAudioSource(playlist);
  }

  //  the below is the setupPlayer()  function
  Future<void> setupPlayer() async {
    await player.setAudioSource(playlist);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void skipForward() {
    final currentPosition = player.position;
    final newPosition = currentPosition + Duration(seconds: 10);
    final duration = player.duration ?? Duration.zero;

    if (newPosition < duration) {
      player.seek(newPosition);
    } else {
      player.seek(duration);
    }
  }

  void skipback() {
    final currentpos = player.position;
    final newpos = player.position - Duration(seconds: 10);
    if (newpos > Duration.zero) {
      player.seek(newpos);
    } else {
      player.seek(Duration.zero);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 10,
        surfaceTintColor: Colors.blueGrey.shade700,
        backgroundColor: Colors.blueGrey.shade800,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: Text("HOME"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/xylo');
                },
                child: Text("XYLO"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/second');
                },
                child: Text("second"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("home"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (cnt % 2 == 0) {
                              player.play();
                              cnt++;
                            } else {
                              player.pause();
                              cnt = 0;
                            }
                          });
                        },
                        child: Icon(Icons.play_arrow_outlined),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<Duration>(
                        stream: player.positionStream,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = player.duration ?? Duration.zero;
                          return Column(
                            children: [
                              Slider(
                                value: position.inMilliseconds.toDouble(),
                                max: duration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  player.seek(
                                      Duration(milliseconds: value.round()));
                                },
                              ),
                              Text(
                                '${position.toString().split('.').first} / ${duration.toString().split('.').first}',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            skipback();
                          });
                        },
                        child: Icon(Icons.fast_rewind_rounded),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            skipForward();
                          });
                        },
                        child: Icon(Icons.forward_10_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//  fit  container inside screen size

