import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passport OCR'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.document_scanner,
              size: 120,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Сканирование паспорта',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Сфотографируйте паспорт — данные распознаются и отправятся в архив на email.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomButton(
              label: 'Сканировать паспорт',
              icon: Icons.camera_alt,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
