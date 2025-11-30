import 'package:flutter/material.dart';
import 'neumorphism_theme.dart';
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
      backgroundColor: Neumorphism.backgroundDark,
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: Neumorphism.neumorphicBox(),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Bienvenido', style: Neumorphism.neumorphicText(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Neumorphism.accent,
                      hintStyle: TextStyle(color: Neumorphism.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    style: Neumorphism.neumorphicText(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Neumorphism.accent,
                      hintStyle: TextStyle(color: Neumorphism.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    style: Neumorphism.neumorphicText(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Neumorphism.accentYouth,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Iniciar sesión', style: Neumorphism.neumorphicText(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: Neumorphism.neumorphicText(color: Colors.redAccent)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
