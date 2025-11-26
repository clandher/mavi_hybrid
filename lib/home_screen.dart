import 'package:flutter/material.dart';
import 'app_dimensions.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final token = args?['token'] ?? '';
    final user = args?['user'] ?? {};
    int _selectedIndex = 0;
    final List<_MenuOption> _options = [
      _MenuOption(
        icon: Icons.payment,
        label: 'Pagos',
        route: '/pagos',
      ),
      _MenuOption(
        icon: Icons.event,
        label: 'Actividades',
        route: '/actividades',
      ),
      _MenuOption(
        icon: Icons.edit_note,
        label: 'Observaciones',
        route: '/actualizarObservaciones',
      ),
    ];
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          backgroundColor: const Color(0xFF181A20),
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: const Color(0xFF22242A),
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
                    const Text(
                      '¡Bienvenido a Home!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Token:', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text(token, style: const TextStyle(color: Colors.white54)),
                    const SizedBox(height: 16),
                    Text('Usuario:', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text('ID: ${user['id'] ?? ''}', style: const TextStyle(color: Colors.white54)),
                    Text('Nombre: ${user['name'] ?? ''}', style: const TextStyle(color: Colors.white54)),
                    Text('Email: ${user['email'] ?? ''}', style: const TextStyle(color: Colors.white54)),
                    Text('Developer: ${user['developer'] ?? ''}', style: const TextStyle(color: Colors.white54)),
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
              selectedItemColor: Colors.tealAccent,
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
      },
    );
  }
}


class _MenuOption {
  final IconData icon;
  final String label;
  final String route;
  const _MenuOption({required this.icon, required this.label, required this.route});
}
