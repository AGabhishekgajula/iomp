import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<bool> login(String username, String password) async {
    final url = Uri.parse('http://192.168.0.131:5001/login'); // Replace with your actual backend URL

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }
}
