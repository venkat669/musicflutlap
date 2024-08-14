import 'package:flutter/material.dart';
import 'package:musicflutlap/pages/firstpage.dart';
import 'package:musicflutlap/pages/homepage.dart';
import 'package:musicflutlap/pages/secondpage.dart';

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
      theme: ThemeData.light(),
      routes: {
        '/home': (context) => homepage(),
        '/xylo': (context) => xylop(),
        '/second': (context) => SecondPage(),
      },
    );
  }
}
