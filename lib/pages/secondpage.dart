import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late AudioPlayer player = AudioPlayer();
  List<FileSystemEntity> mp3Files = [];

  @override
  void initState() {
    super.initState();

    _fetchMp3Files().then((files) {
      setState(() {
        mp3Files = files;
      });
    });

    // Create the audio player.
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.
    player.setReleaseMode(ReleaseMode.stop);

    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSourceAsset('music/gta.mp3');
      await player.resume();
    });
  }

  @override
  void dispose() {
    // Release all sources and dispose the player.
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Player'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: mp3Files.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(mp3Files[index].path.split('/').last),
                  onTap: () async {
                    // Play the selected file
                    await player.setSourceDeviceFile(mp3Files[index].path);
                    await player.resume();
                  },
                );
              },
            ),
          ),
          PlayerWidget(player: player),
        ],
      ),
    );
  }

  Future<List<FileSystemEntity>> _fetchMp3Files() async {
    if (await _requestPermission()) {
      Directory? rootDirectory = Directory('/Storage/Download/');
      return await _scanDirectoryForMp3(rootDirectory);
    }
    return [];
  }

  Future<List<FileSystemEntity>> _scanDirectoryForMp3(
      Directory directory) async {
    // List<File> mp3Files = [];
    // try {
    //   var entities = directory.listSync(recursive: true);
    //   for (var entity in entities) {
    //     if (entity is File && entity.path.endsWith('.mp3')) {
    //       mp3Files.add(entity);
    //     }
    //   }
    // } catch (e) {
    //   print("Error: $e");
    // }
    // return mp3Files;

    String mp3path = directory.toString();
    print(mp3path);
    List<FileSystemEntity> _files;
    List<FileSystemEntity> _songs = [];
    _files = directory.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.mp3')) {
        _songs.add(entity);
      }
    }
    print(_songs);
    print("\n");
    print(" ${_songs.length} ++++ \n");
    return _songs;
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.storage.request();
    print(" this is print " + status.toString());
    return status.isGranted;
  }

  // Future<bool> _requestPermission() async {
  //   if (Platform.isAndroid) {
  //     if (await _isAndroid13OrAbove()) {
  //       var status = await Permission.audio.request();
  //       if (status.isGranted) {
  //         print("Audio permission granted for Android 13 or above");
  //         return true;
  //       } else {
  //         print("Audio permission denied for Android 13 or above");
  //         return false;
  //       }
  //     } else {
  //       var status = await Permission.storage.request();
  //       if (status.isGranted) {
  //         print("Storage permission granted for Android below 13");
  //         return true;
  //       } else {
  //         print("Storage permission denied for Android below 13");
  //         return false;
  //       }
  //     }
  //   } else {
  //     // Handle other platforms (iOS, etc.)
  //     return true;
  //   }
  // }

  // Future<bool> _isAndroid13OrAbove()  {
  //   return Platform.isAndroid &&  (Platform.version) >= '13';
  // }
}

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;

  const PlayerWidget({
    required this.player,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    _initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(fontSize: 16.0),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.grey,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: Colors.grey,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
