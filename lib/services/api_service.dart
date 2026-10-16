import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Для Android-эмулятора: http://10.0.2.2:5000
  // Для реального телефона: http://IP_компа:5000
  // Для Linux desktop: http://localhost:5000
  static const String baseUrl = 'http://localhost:5000';

  static Future<String> sendPassport({
    required String text,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'OK';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
