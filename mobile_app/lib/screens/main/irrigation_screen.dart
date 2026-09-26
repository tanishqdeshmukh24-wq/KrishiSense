import 'package:flutter/material.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  bool _mockIrrigationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  color: Color(0xFF239447),
                  size: 38,
                ),
                const SizedBox(height: 14),
                Text(
                  'Irrigation Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Irrigation decisions are based on sensor and decision-engine data.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Current Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFE8F4EA),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF239447),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Irrigation Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soil moisture is currently within the optimal range.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Irrigation Control',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              value: _mockIrrigationEnabled,
              onChanged: (value) {
                setState(() {
                  _mockIrrigationEnabled = value;
                });
              },
              title: const Text(
                'Demo Control',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Mock control for the prototype. Hardware control will be connected through the backend.',
              ),
              secondary: const Icon(
                Icons.power_settings_new,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: const Color(0xFFFFF8E7),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF9A6A00),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prototype mode: the switch above does not control a real pump. Real irrigation commands will go through the backend and hardware integration layer.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}