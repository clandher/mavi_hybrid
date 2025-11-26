import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:convert';

class SelectStudentScreen extends StatefulWidget {
  const SelectStudentScreen({Key? key}) : super(key: key);

  @override
  State<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends State<SelectStudentScreen> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _loading = true;
  // Eliminado campo no usado

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final response = await ApiService.get('/students');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final students = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterStudents(String value) {
    setState(() {
      _filteredStudents = _students.where((student) {
        final name = (student['name'] ?? '').toString().toLowerCase();
        return name.contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona estudiante'),
        backgroundColor: const Color(0xFF22242A),
      ),
      backgroundColor: const Color(0xFF181A20),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                filled: true,
                fillColor: Colors.white10,
                prefixIcon: Icon(Icons.search, color: Colors.tealAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: _filterStudents,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredStudents.isEmpty
                      ? Center(child: Text('No se encontraron estudiantes', style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return Card(
                              color: Colors.teal.shade900,
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
                                title: Text(student['name'] ?? 'Sin nombre', style: TextStyle(color: Colors.white)),
                                subtitle: Text('ID: ${student['id']}', style: TextStyle(color: Colors.white70)),
                                onTap: () {
                                  Navigator.pop(context, student);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
