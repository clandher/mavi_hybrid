import 'package:flutter/material.dart';
import 'neumorphism_theme.dart';
import 'package:intl/intl.dart';
import 'helpers.dart';
import 'api_service.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'select_student_screen.dart';

class RegisterPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const RegisterPaymentScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<RegisterPaymentScreen> createState() => _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState extends State<RegisterPaymentScreen> {
  List<Map<String, dynamic>> _charges = [];
  bool _loading = true;
  double _paymentAmount = 0.0;
  List<double> _paymentDistribution = [];
  final _amountController = TextEditingController();
  bool _autoDownloadVoucher = true;
  String? _error;
  late Map<String, dynamic> _selectedStudent;

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.student;
    _fetchCharges();
  }

  Future<void> _fetchCharges() async {
    final search = json.encode({
      "studentId": _selectedStudent['id'],
      "amountRemaining": { "\$gt": 0 }
    });
    final response = await ApiService.get('/chargers?s=$search');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final charges = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      setState(() {
        _charges = charges;
        _loading = false;
        _paymentAmount = _getTotalDebt();
        _amountController.text = _paymentAmount.toStringAsFixed(2);
        _updatePaymentDistribution();
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  double _getTotalDebt() {
    return _charges.fold(0.0, (sum, c) => sum + (c['amountRemaining'] ?? 0.0));
  }

  void _updatePaymentDistribution() {
    setState(() {
      double remaining = _paymentAmount;
      _paymentDistribution = [];
      for (var charge in _charges) {
        var rawAmount = charge['amountRemaining'] ?? 0.0;
        final chargeAmount = rawAmount is int ? rawAmount.toDouble() : rawAmount as double;
        if (remaining <= 0) {
          _paymentDistribution.add(0.0);
        } else if (remaining >= chargeAmount) {
          _paymentDistribution.add(chargeAmount);
          remaining -= chargeAmount;
        } else {
          _paymentDistribution.add(remaining);
          remaining = 0.0;
        }
      }
    });
  }

  void _payFullAmount() {
    setState(() {
      _paymentAmount = _getTotalDebt();
      _amountController.text = _paymentAmount.toStringAsFixed(2);
      _updatePaymentDistribution();
    });
  }

  void _onAmountChanged(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    setState(() {
      _paymentAmount = parsed;
      _updatePaymentDistribution();
    });
  }

  Future<void> _submitPayment() async {
    setState(() { _error = null; });
    if (!(_paymentAmount > 0 && _paymentAmount <= _getTotalDebt())) {
      setState(() { _error = 'El monto excede el adeudo total o es cero.'; });
      return;
    }
    final body = {
      "studentId": _selectedStudent['id'],
      "amount": _paymentAmount,
      "paymentDate": DateTime.now().toIso8601String(),
      "voucher": ".",
      "charges": _charges.map((c) => c['id']).toList(),
    };
    final response = await ApiService.post('/payments', body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context); // Sale de RegisterPaymentScreen
    } else {
      setState(() { _error = 'Error al registrar el pago: ${response.body}'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar pago', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22242A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF181A20),
      body: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF3A3F47)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info del usuario seleccionado
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final nuevoUsuario = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectStudentScreen(),
                        ),
                      );
                      if (nuevoUsuario != null && nuevoUsuario is Map<String, dynamic>) {
                        setState(() {
                          _selectedStudent = nuevoUsuario;
                          _loading = true;
                        });
                        await _fetchCharges();
                      }
                    },
                    hoverColor: const Color(0xFF2C2F36),
                    child: Card(
                      color: const Color(0xFF22242A),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: ListTile(
                          leading: (_selectedStudent['photo'] != null)
                              ? FutureBuilder<Uint8List?>(
                                  future: ApiService.fetchStudentPhotoBytes(
                                    _selectedStudent['id'],
                                    _selectedStudent['photo'],
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Color(0xFF23252B),
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                      );
                                    }
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return CircleAvatar(
                                        radius: 24,
                                        backgroundImage: MemoryImage(snapshot.data!),
                                        backgroundColor: Color(0xFF23252B),
                                      );
                                    }
                                    return CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Color(0xFF23252B),
                                      child: Icon(Icons.person, color: Colors.white, size: 24),
                                    );
                                  },
                                )
                              : CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Color(0xFF23252B),
                                  child: Icon(Icons.person, color: Colors.white, size: 24),
                                ),
                          title: Text(
                            _selectedStudent['name'] ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white, decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('Monto a pagar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    Stack(
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white10,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            hintText: 'Monto',
                            hintStyle: TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          onChanged: _onAmountChanged,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: ElevatedButton(
                            onPressed: _payFullAmount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A3F47),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 2,
                            ),
                            child: const Text('Pagar total'),
                          ),
                        ),
                      ],
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_error!, style: TextStyle(color: Colors.redAccent)),
                    ),
                  if (_getTotalDebt() - _paymentAmount > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('Monto total restante: ' + formatCurrency(_getTotalDebt() - _paymentAmount), style: TextStyle(color: Color(0xFF3A3F47))),
                              ),
                  const SizedBox(height: 18),
                  Text('Cargos pendientes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Expanded(
                    child: _charges.isEmpty
                        ? Center(child: Text('No hay cargos para este estudiante', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            itemCount: _charges.length,
                            itemBuilder: (context, i) {
                              final cargo = _charges[i];
                              final covered = _paymentDistribution.length > i ? _paymentDistribution[i] : 0.0;
                              final remaining = (cargo['amountRemaining'] ?? 0.0) - covered;
                              final actividad = cargo['activity'] ?? {};
                              final tipo = actividad['type'] ?? {};
                              final concepto = cargo['concept'] ?? cargo['concepto'] ?? cargo['name'] ?? 'Cargo';
                              final fechaCargo = cargo['chargeDate'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(cargo['chargeDate'])) : '';
                              final fechaActividad = actividad['startDate'] != null && tipo['format'] != null
                                  ? DateFormat(tipo['format'].replaceAll('(', '').replaceAll(')', '')).format(DateTime.parse(actividad['startDate']))
                                  : (actividad['startDate'] ?? '');
                              return Card(
                                color: const Color(0xFF22242A),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$concepto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      if (actividad.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2.0),
                                          child: Text('${actividad['description'] ?? ''} - $fechaActividad', style: TextStyle(color: Colors.white70)),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text('Fecha de cargo: $fechaCargo', style: TextStyle(color: Colors.white38)),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (covered > 0)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                          Text('A pagar', style: TextStyle(color: Color(0xFF3A3F47))),
                                                          Text(formatCurrency(covered), style: TextStyle(color: Color(0xFF3A3F47), fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          if (remaining > 0)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Pendiente', style: TextStyle(color: Colors.white70)),
                                                Text(formatCurrency(remaining), style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _autoDownloadVoucher,
                        onChanged: (val) {
                          setState(() { _autoDownloadVoucher = val ?? true; });
                        },
                            activeColor: const Color(0xFF3A3F47),
                      ),
                      Text('Descargar voucher', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.payment),
                      label: Text('Realizar pago'),
                      style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A3F47),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _submitPayment,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}