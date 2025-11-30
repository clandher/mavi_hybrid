import 'package:flutter/material.dart';
import 'app_dimensions.dart';
import 'neumorphism_theme.dart';

class ObservationsScreen extends StatelessWidget {
  const ObservationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neumorphism.backgroundDark,
      appBar: AppBar(
        title: Text('Actualizar observaciones', style: Neumorphism.neumorphicText(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Neumorphism.accent,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: AppDimensions.width,
          height: AppDimensions.height,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: Neumorphism.neumorphicBox(),
            child: Text(
              'Pantalla para actualizar observaciones',
              style: Neumorphism.neumorphicText(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
