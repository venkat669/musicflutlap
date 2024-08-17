import 'package:flutter/material.dart';
import 'package:musicflutlap/pages/firstpage.dart';
import 'package:musicflutlap/pages/forthpg.dart';
import 'package:musicflutlap/pages/homepage.dart';
import 'package:musicflutlap/pages/secondpage.dart';
import 'package:musicflutlap/pages/thirdpg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: homepage(),
      theme: ThemeData.dark(),
      routes: {
        '/home': (context) => homepage(),
        '/xylo': (context) => xylop(),
        '/second': (context) => SecondPage(),
        '/thirdpg': (context) => Thirdpg(),
        '/forth': (context) => Mp3Scanner(),
      },
    );
  }
}
