import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const PassportApp());

class PassportApp extends StatelessWidget {
  const PassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passport OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
