import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'neumorphism_theme.dart';
import 'api_service.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  String _formatCurrency(dynamic value) {
    final amount = (value is num) ? value.toDouble() : 0.0;
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\u0024', decimalDigits: 2);
    return formatter.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final response = await ApiService.get('/students?includeActivities=true');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final students = data.map<Map<String, dynamic>>((e) {
        final student = Map<String, dynamic>.from(e);
        final activities = (student['activities'] ?? []) as List<dynamic>;
        double totalDebt = 0;
        int activitiesWithDebt = 0;
        for (var act in activities) {
          final debt = (act['debt'] ?? 0).toDouble();
          if (debt > 0) activitiesWithDebt++;
          totalDebt += debt;
        }
        student['totalDebt'] = totalDebt;
        student['activitiesWithDebt'] = activitiesWithDebt;
        return student;
      }).toList();
      // Sort by debt descending, handle nulls
      students.sort((a, b) {
        final bDebt = b['debt'] is num ? (b['debt'] as num).toDouble() : 0.0;
        final aDebt = a['debt'] is num ? (a['debt'] as num).toDouble() : 0.0;
        return bDebt.compareTo(aDebt);
      });
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
      // Sort filtered list by debt descending, handle nulls
      _filteredStudents.sort((a, b) {
        final bDebt = b['debt'] is num ? (b['debt'] as num).toDouble() : 0.0;
        final aDebt = a['debt'] is num ? (a['debt'] as num).toDouble() : 0.0;
        return bDebt.compareTo(aDebt);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecciona estudiante',
          style: Neumorphism.neumorphicText(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Neumorphism.textPrimary,
          ),
        ),
        backgroundColor: Neumorphism.accent,
        elevation: 0,
      ),
      backgroundColor: Neumorphism.backgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                filled: true,
                fillColor: Neumorphism.highlight,
                prefixIcon: Icon(Icons.search, color: Neumorphism.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Neumorphism.shadow, width: 0.5),
                ),
                hintStyle: TextStyle(color: Neumorphism.textSecondary),
              ),
              style: TextStyle(color: Neumorphism.textPrimary),
              onChanged: _filterStudents,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: Neumorphism.textSecondary))
                  : _filteredStudents.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron estudiantes',
                        style: TextStyle(color: Neumorphism.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        return Card(
                          color: Neumorphism.highlight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: (student['photo'] != null)
                                  ? FutureBuilder<Uint8List?>(
                                      future: ApiService.fetchStudentPhotoBytes(
                                        student['id'],
                                        student['photo'],
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Neumorphism.shadow,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Neumorphism.textSecondary),
                                          );
                                        }
                                        if (snapshot.hasData && snapshot.data != null) {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundImage: MemoryImage(snapshot.data!),
                                            backgroundColor: Neumorphism.shadow,
                                          );
                                        }
                                        return CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Neumorphism.shadow,
                                          child: Icon(Icons.person, color: Neumorphism.textPrimary, size: 24),
                                        );
                                      },
                                    )
                                  : CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Neumorphism.shadow,
                                      child: Icon(Icons.person, color: Neumorphism.textPrimary, size: 24),
                                    ),
                              title: Text(
                                student['name'] ?? 'Sin nombre',
                                style: TextStyle(color: Neumorphism.textPrimary),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    'Deuda: ',
                                    style: TextStyle(
                                      color: Neumorphism.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(student['debt']),
                                    style: TextStyle(
                                      color: (student['debt'] is num && (student['debt'] as num) > 0)
                                          ? Colors.amber[800]
                                          : Neumorphism.textSecondary,
                                      fontWeight: (student['debt'] is num && (student['debt'] as num) > 0)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context, student);
                              },
                            ),
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
