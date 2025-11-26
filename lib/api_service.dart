import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ApiService {
      static Future<Uint8List?> fetchStudentPhotoBytes(int studentId, String photoId) async {
        final url = '$host/students/$studentId/photo?id=$photoId';
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
        return null;
      }
    static Future<String?> fetchStudentPhotoUrl(int studentId, String photoId) async {
      final url = '$host/students/$studentId/photo?id=$photoId';
      print(url);
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.body; // Ajusta si el backend responde diferente
      }
      return null;
    }
  static String host = 'http://localhost:3000';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get headers {
    if (_token != null) {
      return {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  static Future<http.Response> get(String endpoint) {
    return http.get(Uri.parse('$host$endpoint'), headers: headers);
  }

  static Future<http.Response> post(String endpoint, dynamic body) {
    return http.post(
      Uri.parse('$host$endpoint'),
      headers: headers,
      body: body is String ? body : body != null ? body is Map ? body : body : body != null ? body : null,
    );
  }
  // Mejor: serializar body si es Map
  // static Future<http.Response> post(String endpoint, dynamic body) {
  //   return http.post(
  //     Uri.parse('$host$endpoint'),
  //     headers: headers,
  //     body: body is String ? body : json.encode(body),
  //   );
  // }
}