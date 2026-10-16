import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class SuccessScreen extends StatelessWidget {
  final String message;

  const SuccessScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Успех')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 120, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Архив отправлен!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 40),
            CustomButton(
              label: 'На главную',
              icon: Icons.home,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
