import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const KrishiSenseApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);

class KrishiSenseApp extends StatelessWidget {
  const KrishiSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KrishiSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF7FAF5),
      ),
      routerConfig: _router,
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KrishiSense'),
        actions: [
          IconButton(
            tooltip: 'Alerts',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Good evening, Farmer',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('Your farm health at a glance.'),
          SizedBox(height: 24),
          _InfoCard(
            title: 'Prototype Farm',
            subtitle: 'Field 1 • Zone A1',
            icon: Icons.agriculture,
          ),
          SizedBox(height: 12),
          _InfoCard(
            title: 'Soil Moisture',
            subtitle: 'Connect sensor data to see the latest reading',
            icon: Icons.water_drop_outlined,
          ),
          SizedBox(height: 12),
          _InfoCard(
            title: 'Crop Analysis',
            subtitle: 'AI-assisted crop health analysis',
            icon: Icons.camera_alt_outlined,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
