import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final url = Uri.parse('http://localhost:3000/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'tsubasa@nankatsu.jp',
        'password': 'SoraWoKakeru11',
      }),
    );
    setState(() {
      _loading = false;
    });
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _user = Map<String, dynamic>.from(data['user']);
      ApiService.setToken(_token!);
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'token': _token, 'user': _user},
      );
    } else {
      setState(() {
        _error = 'Login failed: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email: tsubasa@nankatsu.jp'),
            const Text('Password: SoraWoKakeru11'),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
