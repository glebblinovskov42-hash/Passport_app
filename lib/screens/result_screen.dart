import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import 'success_screen.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late TextEditingController _textController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _ocrLoading = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _runOcrOnServer();
  }

  // Отправляем фото на сервер для распознавания
  Future<void> _runOcrOnServer() async {
    try {
      final text = await ApiService.recognizePassport(widget.imagePath);

      if (!mounted) return;

      setState(() {
        _textController.text = text;
        _ocrLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _textController.text = 'Ошибка OCR: $e';
        _ocrLoading = false;
      });
    }
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final text = _textController.text.trim();

    if (_ocrLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дождитесь завершения распознавания')),
      );
      return;
    }

    if (text.isEmpty || text.startsWith('Ошибка OCR:')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет распознанного текста. Попробуйте ещё раз.'),
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный email получателя')),
      );
      return;
    }

    if (password.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите пароль для архива')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final message = await ApiService.sendPassport(
        text: text,
        email: email,
        password: password,
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
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            _ocrLoading
                ? const Center(child: CircularProgressIndicator())
                : TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
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
            const SizedBox(height: 16),
            const Text('Пароль архива:'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: 'Введите пароль для открытия архива',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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