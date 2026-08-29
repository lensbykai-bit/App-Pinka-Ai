import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PinkaAiApp());
}

class PinkaAiApp extends StatelessWidget {
  const PinkaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PINKA Ai',
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
