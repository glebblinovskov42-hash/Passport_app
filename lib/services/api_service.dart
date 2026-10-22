import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Для Android-эмулятора: http://10.0.2.2:5000
  // Для реального телефона (с adb reverse): http://localhost:5000
  // Для Linux desktop: http://localhost:5000
  static const String baseUrl = 'http://localhost:5000';

  // 1. Отправка фото на сервер для OCR
  static Future<String> recognizePassport(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr'));

    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      return data['text'] ?? '';
    } else {
      throw Exception('Ошибка сервера: $responseData');
    }
  }

  // 2. Отправка текста на сервер для архивации и email
  static Future<String> sendPassport({
    required String text,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'OK';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}