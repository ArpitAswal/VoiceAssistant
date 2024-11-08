import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voice_assistant/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Genie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent.shade400),
        primaryColor: Colors.tealAccent.shade400,
        appBarTheme: AppBarTheme(color: Colors.tealAccent.shade400, centerTitle: true, titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18)),
        scaffoldBackgroundColor: Colors.grey.shade200,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
