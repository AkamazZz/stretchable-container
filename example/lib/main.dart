import 'package:flutter/material.dart';

import 'playground/playground_screen.dart';

void main() {
  runApp(const StretchableContainerExampleApp());
}

class StretchableContainerExampleApp extends StatefulWidget {
  const StretchableContainerExampleApp({super.key});

  @override
  State<StretchableContainerExampleApp> createState() =>
      _StretchableContainerExampleAppState();
}

class _StretchableContainerExampleAppState
    extends State<StretchableContainerExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6EF7)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF78A8FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: PlaygroundScreen(
        themeMode: _themeMode,
        onThemeModeChanged: (nextMode) {
          setState(() {
            _themeMode = nextMode;
          });
        },
      ),
    );
  }
}
