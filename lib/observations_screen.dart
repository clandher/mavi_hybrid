import 'package:flutter/material.dart';
import 'app_dimensions.dart';

class ObservationsScreen extends StatelessWidget {
  const ObservationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Actualizar observaciones'),
        backgroundColor: const Color(0xFF22242A),
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: AppDimensions.width,
          height: AppDimensions.height,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF22242A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Pantalla para actualizar observaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
