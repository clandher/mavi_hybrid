import 'package:flutter/material.dart';
import 'app_dimensions.dart';
import 'neumorphism_theme.dart';


class _MenuOption {
  final IconData icon;
  final String label;
  final String route;
  const _MenuOption({required this.icon, required this.label, required this.route});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final token = args?['token'] ?? '';
    final user = args?['user'] ?? {};
    final List<_MenuOption> _options = [
      const _MenuOption(icon: Icons.payment, label: 'Pagos', route: '/pagos'),
      const _MenuOption(icon: Icons.event, label: 'Actividades', route: '/actividades'),
      const _MenuOption(icon: Icons.edit_note, label: 'Observaciones', route: '/actualizarObservaciones'),
    ];
    return Scaffold(
      backgroundColor: Neumorphism.backgroundDark,
      appBar: AppBar(
        title: Text('Home', style: Neumorphism.neumorphicText(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Neumorphism.accent,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: AppDimensions.width,
          height: AppDimensions.height,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: Neumorphism.neumorphicBox(borderRadius: 8.0),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Bienvenido a Home!', style: Neumorphism.neumorphicText(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Token:', style: Neumorphism.neumorphicText(fontWeight: FontWeight.bold, color: Neumorphism.textSecondary)),
                      Text(token, style: Neumorphism.neumorphicText(color: Neumorphism.textSecondary)),
                      const SizedBox(height: 16),
                      Text('Usuario:', style: Neumorphism.neumorphicText(fontWeight: FontWeight.bold, color: Neumorphism.textSecondary)),
                      Text('ID: ${user['id'] ?? ''}', style: Neumorphism.neumorphicText(color: Neumorphism.textSecondary)),
                      Text('Nombre: ${user['name'] ?? ''}', style: Neumorphism.neumorphicText(color: Neumorphism.textSecondary)),
                      Text('Email: ${user['email'] ?? ''}', style: Neumorphism.neumorphicText(color: Neumorphism.textSecondary)),
                      Text('Developer: ${user['developer'] ?? ''}', style: Neumorphism.neumorphicText(color: Neumorphism.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _options.map((option) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, option.route);
                      },
                      child: Container(
                          decoration: Neumorphism.neumorphicBox(borderRadius: 8.0),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                        child: Column(
                          children: [
                            Icon(option.icon, color: Neumorphism.accentYouth, size: 32),
                            const SizedBox(height: 8),
                            Text(option.label, style: Neumorphism.neumorphicText()),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF22242A),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF22242A),
          selectedItemColor: Neumorphism.accentYouth,
          unselectedItemColor: Colors.white38,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            Navigator.pushNamed(context, _options[index].route);
          },
          items: _options
              .map((option) => BottomNavigationBarItem(
                    icon: Icon(option.icon),
                    label: option.label,
                  ))
              .toList(),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
    );
  }
}
// ...existing code...
