import 'package:flutter/material.dart';
import 'neumorphism_theme.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:mavi_hybrid/register_payment_screen.dart';
import 'package:mavi_hybrid/select_student_screen.dart';
import 'api_service.dart';
import 'app_dimensions.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late Future<List<Payment>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = fetchPayments();
  }


  Future<List<Payment>> fetchPayments() async {
    final response = await ApiService.get('/payments');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Eliminado: manejo de _firstPaymentJson
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar pagos: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchPaymentCharges(int paymentId) async {
    final response = await ApiService.get('/payments/$paymentId/charges');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al cargar cargos: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          title: const Text('Pagos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: const Color(0xFF22242A),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.tealAccent),
          bottom: const TabBar(
            indicatorColor: Colors.tealAccent,
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(icon: Icon(Icons.payment), text: 'Pagos realizados'),
              Tab(icon: Icon(Icons.verified), text: 'Verificar pagos'),
            ],
          ),
        ),
        body: Center(
          child: SizedBox(
            width: AppDimensions.width,
            height: AppDimensions.height,
            child: TabBarView(
              children: [
                // Tab 1: Pagos realizados
                FutureBuilder<List<Payment>>(
                  future: _paymentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay pagos registrados', style: TextStyle(color: Colors.white70)));
                    }
                    final payments = snapshot.data!;
                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final student = payment.student;
                        final date = DateTime.tryParse(payment.paymentDate);
                        final formattedDate = date != null
                            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                            : payment.paymentDate;
                        final formattedAmount = NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(payment.amount);
                        return Card(
                          color: const Color(0xFF22242A),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [ 
                                    Text(formattedAmount, style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.w600, fontSize: 16)),
                                    const Spacer(),
                                    const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                                    const SizedBox(width: 4),
                                    Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (student != null && student['photo'] != null)
                                      FutureBuilder<Uint8List?>(
                                        future: ApiService.fetchStudentPhotoBytes(student['id'], student['photo']),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircleAvatar(radius: 24, backgroundColor: Color(0xFF23252B), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent));
                                          }
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return CircleAvatar(radius: 24, backgroundImage: MemoryImage(snapshot.data!), backgroundColor: const Color(0xFF23252B));
                                          }
                                          return const CircleAvatar(radius: 24, backgroundColor: Color(0xFF23252B), child: Icon(Icons.person, size: 24, color: Colors.white));
                                        },
                                      )
                                    else
                                      const CircleAvatar(radius: 24, backgroundColor: Color(0xFF23252B), child: Icon(Icons.person, size: 24, color: Colors.white)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        student != null ? student['name'] ?? 'Sin nombre' : 'Estudiante: ${payment.studentId}',
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Divider(color: Colors.tealAccent.withOpacity(0.3), thickness: 1),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xFF22242A).withOpacity(0.1),
                                      foregroundColor: Colors.tealAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.receipt_long, size: 18),
                                    label: const Text('Ver cargos', style: TextStyle(fontSize: 14)),
                                    onPressed: () async {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: const Color(0xFF23252B),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                        ),
                                        builder: (context) {
                                          return FutureBuilder<Map<String, dynamic>>(
                                            future: ApiService.get('/payments/${payment.id}/charges').then((response) {
                                              if (response.statusCode == 200) {
                                                return json.decode(response.body) as Map<String, dynamic>;
                                              } else {
                                                throw Exception('Error al cargar cargos: \\${response.body}');
                                              }
                                            }),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator(color: Colors.tealAccent));
                                              }
                                              if (snapshot.hasError) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Text('Error: \\${snapshot.error}', style: TextStyle(color: Colors.redAccent)),
                                                );
                                              }
                                              final data = snapshot.data;
                                              final cargos = data != null ? data['paymentCharges'] as List<dynamic>? : null;
                                              return CargosModal(cargos: cargos);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Tab 2: Verificar pagos
                _buildVerificarPagos(),
              ],
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabIndex = DefaultTabController.of(context).index;
            if (tabIndex == 0) {
              return FloatingActionButton.extended(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Registrar nuevo pago'),
                onPressed: () async {
                  final selectedStudent = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectStudentScreen(),
                    ),
                  );
                  if (selectedStudent != null) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterPaymentScreen(student: selectedStudent),
                      ),
                    );
                    setState(() {
                      _paymentsFuture = fetchPayments();
                    });
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildVerificarPagos() {
    return const Center(
      child: Text(
        'Pantalla para verificar pagos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class Payment {
  final int id;
  final int studentId;
  final double amount;
  final String paymentDate;
  final String voucher;
  final Map<String, dynamic>? student;
  final List<dynamic>? charges;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.voucher,
    this.student,
    this.charges,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      studentId: json['studentId'],
      amount: (json['amount'] is int) ? (json['amount'] as int).toDouble() : (json['amount'] as num).toDouble(),
      paymentDate: json['paymentDate'].toString(),
      voucher: json['voucher'] ?? '',
      student: json['student'] != null ? Map<String, dynamic>.from(json['student']) : null,
      charges: json['charges'] != null ? List<dynamic>.from(json['charges']) : null,
    );
  }
}

class CargosModal extends StatelessWidget {
  final List<dynamic>? cargos;
  const CargosModal({Key? key, this.cargos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF22242A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cargos aplicados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          if (cargos == null || cargos?.isEmpty == true)
            const Text('No hay cargos para este pago', style: TextStyle(color: Colors.white70)),
          if (cargos?.isNotEmpty == true)
            ...cargos!.map((cargo) {
              final collection = cargo['collection'] ?? {};
              final actividad = cargo['activity'] ?? {};
              final concepto = collection['concept'] ?? 'Cargo';
              final monto = cargo['amount'] ?? 0.0;
              final fechaCargo = collection['chargeDate'] != null
                  ? DateFormat('dd/MM/yyyy').format(DateTime.parse(collection['chargeDate']))
                  : '';
              final descripcionActividad = actividad['description'] ?? '';
              return Card(
                color: const Color(0xFF22242A),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(concepto, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (descripcionActividad.isNotEmpty)
                        Text(descripcionActividad, style: const TextStyle(color: Colors.white70)),
                      if (fechaCargo.isNotEmpty)
                        Text('Fecha de  cargso: $fechaCargo', style: const TextStyle(color: Colors.white38)),
                    ],
                  ),
                  trailing: Text(NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(monto), style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

