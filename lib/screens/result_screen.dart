import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import 'success_screen.dart';

class ResultScreen extends StatefulWidget {
  final String recognizedText;

  const ResultScreen({super.key, required this.recognizedText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final TextEditingController _textController;
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recognizedText);
  }

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      final message = await ApiService.sendPassport(
        text: _textController.text,
        email: _emailController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(message: message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Распознанный текст:'),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Email получателя:'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'example@gmail.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Отправить на email',
              icon: Icons.send,
              loading: _loading,
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}
