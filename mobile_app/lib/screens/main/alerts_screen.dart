import 'package:flutter/material.dart';

import '../../data/models/alert_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  List<AlertModel> _getMockAlerts() {
    final now = DateTime.now();

    return [
      AlertModel(
        id: 'alert_001',
        title: 'Node Offline',
        message:
        'NODE_003 has not sent a recent reading. Check the sensor connection.',
        type: 'node',
        severity: 'warning',
        timestamp: now.subtract(const Duration(minutes: 18)),
        isRead: false,
      ),
      AlertModel(
        id: 'alert_002',
        title: 'Crop Health Warning',
        message:
        'AI analysis detected a possible crop-health issue requiring inspection.',
        type: 'crop',
        severity: 'warning',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      AlertModel(
        id: 'alert_003',
        title: 'Soil Moisture Status',
        message:
        'Zone A1 soil moisture is currently within the optimal range.',
        type: 'soil',
        severity: 'info',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _getMockAlerts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF239447),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farm Alerts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Important updates from your farm.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Recent Alerts',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          ...alerts.map(
                (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertCard(alert: alert),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertCard({
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = alert.severity == 'warning';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFFFE2B8)
              : const Color(0xFFE0E8E3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isWarning
                  ? const Color(0xFFFFF3DD)
                  : const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isWarning
                  ? Icons.warning_amber_outlined
                  : Icons.info_outline,
              color: isWarning
                  ? const Color(0xFFB45F06)
                  : const Color(0xFF239447),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF073D32),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF526B70),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatTime(alert.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '${time.day}/${time.month}/${time.year} • $hour:$minute';
  }
}