import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'result_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Камера')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera, size: 120, color: Colors.grey),
              const SizedBox(height: 24),
              const Text(
                'Здесь будет превью камеры',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              CustomButton(
                label: 'Сделать фото (заглушка)',
                icon: Icons.camera,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResultScreen(
                        recognizedText: 'Gleb Blinovskov, passport 1234 567890',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
