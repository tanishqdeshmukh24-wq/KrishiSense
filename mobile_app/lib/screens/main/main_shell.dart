import 'package:flutter/material.dart';

import 'package:krishisense_mobile/data/models/farm_model.dart';
import 'package:krishisense_mobile/data/models/field_model.dart';
import 'package:krishisense_mobile/data/models/node_model.dart';
import 'package:krishisense_mobile/data/models/sensor_reading_model.dart';
import 'package:krishisense_mobile/data/models/zone_model.dart';
import '../../data/repositories/repository_provider.dart';
import '../dashboard_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FarmScreen(),
    SensorsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.agriculture_outlined),
            selectedIcon: Icon(Icons.agriculture),
            label: 'Farm',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FarmModel>(
      future: mockFarmRepository.getFarm(),
      builder: (context, farmSnapshot) {
        if (farmSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (farmSnapshot.hasError || !farmSnapshot.hasData) {
          return const _ErrorScreen(
            message: 'Unable to load farm data.',
          );
        }

        final farm = farmSnapshot.data!;

        return FutureBuilder<List<FieldModel>>(
          future: mockFarmRepository.getFields(farm.id),
          builder: (context, fieldSnapshot) {
            if (fieldSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (fieldSnapshot.hasError || !fieldSnapshot.hasData) {
              return const _ErrorScreen(
                message: 'Unable to load field data.',
              );
            }

            final fields = fieldSnapshot.data ?? [];

            final totalZones = fields.fold<int>(
              0,
                  (total, field) => total + field.zoneIds.length,
            );

            return Scaffold(
              backgroundColor: const Color(0xFFF7FAF5),
              appBar: AppBar(
                title: const Text('My Farm'),
                backgroundColor: const Color(0xFFF7FAF5),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EEDB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.agriculture_outlined,
                            color: Color(0xFF239447),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                farm.location,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _FarmStatCard(
                          value: fields.length.toString(),
                          label:
                          fields.length == 1 ? 'Field' : 'Fields',
                          icon: Icons.landscape_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FarmStatCard(
                          value: totalZones.toString(),
                          label:
                          totalZones == 1 ? 'Zone' : 'Zones',
                          icon: Icons.grid_view_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Fields',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  if (fields.isEmpty)
                    const _EmptyStateCard(
                      message: 'No fields have been added yet.',
                    )
                  else
                    ...fields.map(
                          (field) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 12),
                        child: _NavigationCard(
                          icon: Icons.landscape_outlined,
                          title: field.name,
                          subtitle: field.zoneIds.length == 1
                              ? '1 zone • View field'
                              : '${field.zoneIds.length} zones • View field',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FieldOverviewScreen(
                                      fieldId: field.id,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
class FieldOverviewScreen extends StatelessWidget {
  final String fieldId;

  const FieldOverviewScreen({
    super.key,
    required this.fieldId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FieldModel?>(
      future: _getField(),
      builder: (context, fieldSnapshot) {
        if (fieldSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (fieldSnapshot.hasError ||
            !fieldSnapshot.hasData ||
            fieldSnapshot.data == null) {
          return const _ErrorScreen(
            message: 'Unable to load field data.',
          );
        }

        final field = fieldSnapshot.data!;

        return FutureBuilder<List<ZoneModel>>(
          future: mockFarmRepository.getZones(field.id),
          builder: (context, zoneSnapshot) {
            if (zoneSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (zoneSnapshot.hasError ||
                !zoneSnapshot.hasData) {
              return const _ErrorScreen(
                message: 'Unable to load zone data.',
              );
            }

            final zones = zoneSnapshot.data ?? [];

            return Scaffold(
              backgroundColor: const Color(0xFFF7FAF5),
              appBar: AppBar(
                title: Text(field.name),
                backgroundColor: const Color(0xFFF7FAF5),
              ),
              body: ListView(
                padding:
                const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EEDB),
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.landscape_outlined,
                            color: Color(0xFF239447),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${zones.length} ${zones.length == 1 ? 'zone' : 'zones'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Zones & Sensor Nodes',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),

                  const SizedBox(height: 12),

                  if (zones.isEmpty)
                    const _EmptyStateCard(
                      message:
                      'No zones have been added to this field yet.',
                    )
                  else
                    ...zones.map(
                          (zone) => _ZoneWithNodesCard(
                        zone: zone,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<FieldModel?> _getField() async {
    final farm = await mockFarmRepository.getFarm();
    final fields =
    await mockFarmRepository.getFields(farm.id);

    for (final field in fields) {
      if (field.id == fieldId) {
        return field;
      }
    }

    return null;
  }
}
class _ZoneWithNodesCard extends StatelessWidget {
  final ZoneModel zone;

  const _ZoneWithNodesCard({
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NodeModel>>(
      future: mockFarmRepository.getNodes(zone.id),
      builder: (context, nodeSnapshot) {
        if (nodeSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (nodeSnapshot.hasError ||
            !nodeSnapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Unable to load nodes for ${zone.name}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final nodes = nodeSnapshot.data ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE3EAE4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4EA),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Color(0xFF239447),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${nodes.length} ${nodes.length == 1 ? 'sensor node' : 'sensor nodes'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (nodes.isNotEmpty) ...[
                const SizedBox(height: 14),

                ...nodes.map(
                      (node) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: const Color(0xFFF7FAF5),
                      borderRadius:
                      BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius:
                        BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SensorDetailsScreen(
                                    nodeId: node.id,
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding:
                          const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: node.isOnline
                                      ? const Color(0xFFDFF3E3)
                                      : const Color(0xFFFDE7E7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.sensors_outlined,
                                  color: node.isOnline
                                      ? const Color(0xFF239447)
                                      : const Color(0xFFC94A4A),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      node.id,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      node.isOnline
                                          ? 'Online • ${node.soilMoisture.toStringAsFixed(0)}% moisture'
                                          : 'Offline • Last known ${node.soilMoisture.toStringAsFixed(0)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding:
                  const EdgeInsets.only(top: 14),
                  child: Text(
                    'No sensor nodes in this zone.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
class FieldScreen extends StatelessWidget {
  final String farmId;

  const FieldScreen({
    super.key,
    required this.farmId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FieldModel>>(
      future: mockFarmRepository.getFields(farmId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorScreen(
            message: 'Unable to load field data.',
          );
        }

        final fields = snapshot.data ?? [];

        return _SimpleNavigationScreen(
          title: 'Fields',
          subtitle: 'Select a field to continue',
          icon: Icons.landscape_outlined,
          cards: fields.map((field) {
            return _NavigationCardData(
              icon: Icons.landscape_outlined,
              title: field.name,
              subtitle: field.zoneIds.length == 1
                  ? '1 zone'
                  : '${field.zoneIds.length} zones',
              destination: ZoneScreen(
                fieldId: field.id,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ZoneScreen extends StatelessWidget {
  final String fieldId;

  const ZoneScreen({
    super.key,
    required this.fieldId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ZoneModel>>(
      future: mockFarmRepository.getZones(fieldId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorScreen(
            message: 'Unable to load zone data.',
          );
        }

        final zones = snapshot.data ?? [];

        return _SimpleNavigationScreen(
          title: 'Zones',
          subtitle: 'Select a zone to view its nodes',
          icon: Icons.grid_view_rounded,
          cards: zones.map((zone) {
            return _NavigationCardData(
              icon: Icons.grid_view_rounded,
              title: zone.name,
              subtitle: zone.nodeIds.length == 1
                  ? '1 sensor node'
                  : '${zone.nodeIds.length} sensor nodes',
              destination: NodeListScreen(
                zoneId: zone.id,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class NodeListScreen extends StatelessWidget {
  final String zoneId;

  const NodeListScreen({
    super.key,
    required this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NodeModel>>(
      future: mockFarmRepository.getNodes(zoneId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorScreen(
            message: 'Unable to load sensor nodes.',
          );
        }

        final nodes = snapshot.data ?? [];

        return _SimpleNavigationScreen(
          title: 'Sensor Nodes',
          subtitle: 'Select a node to view sensor details',
          icon: Icons.sensors_outlined,
          cards: nodes.map((node) {
            return _NavigationCardData(
              icon: Icons.sensors_outlined,
              title: node.id,
              subtitle: node.isOnline
                  ? 'Online • Sensor data available'
                  : 'Offline • Last reading available',
              destination: NodeScreen(
                nodeId: node.id,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class NodeScreen extends StatelessWidget {
  final String nodeId;

  const NodeScreen({
    super.key,
    required this.nodeId,
  });

  String _formatLastUpdated(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${difference.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NodeModel?>(
      future: mockFarmRepository.getNode(nodeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorScreen(
            message: 'Unable to load node data.',
          );
        }

        final node = snapshot.data!;

        return _SimpleNavigationScreen(
          title: node.id,
          subtitle: node.isOnline
              ? 'Online • Sensor node'
              : 'Offline • Sensor node',
          icon: Icons.sensors,
          extraContent: Column(
            children: [
              _NodeStatusCard(
                isOnline: node.isOnline,
                lastUpdated: _formatLastUpdated(node.lastUpdated),
                zoneId: node.zoneId,
              ),
              const SizedBox(height: 12),
              _NavigationCard(
                icon: Icons.analytics_outlined,
                title: 'Sensor Details',
                subtitle:
                'View soil moisture, temperature and humidity',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SensorDetailsScreen(
                        nodeId: node.id,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class SensorDetailsScreen extends StatelessWidget {
  final String nodeId;

  const SensorDetailsScreen({
    super.key,
    required this.nodeId,
  });

  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '${time.day}/${time.month}/${time.year} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nodeId),
      ),
      body: FutureBuilder<SensorReadingModel?>(
        future: mockFarmRepository.getLatestReading(nodeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }

          if (snapshot.hasError) {
            return const _ErrorScreen(
              message: 'Unable to load sensor data.',
            );
          }

          final reading = snapshot.data;

          if (reading == null) {
            return const _ErrorScreen(
              message: 'No sensor data available.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sensor Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Latest readings from $nodeId',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Soil Moisture',
                        value: '${reading.soilMoisture.toStringAsFixed(0)}%',
                        subtitle: 'Current level', status: '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        title: 'Temperature',
                        value: '${reading.temperature.toStringAsFixed(0)}°C',
                        subtitle: 'Current temperature', status: '',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Humidity',
                        value: '${reading.humidity.toStringAsFixed(0)}%',
                        subtitle: 'Current humidity', status: '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        title: 'Rainfall',
                        value: reading.rainfall == null
                            ? 'N/A'
                            : '${reading.rainfall}',
                        subtitle: 'Latest reading', status: '',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Updated',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(reading.timestamp),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Sensor Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.sensors,
                    ),
                    title: Text(nodeId),
                    subtitle: const Text(
                      'Connected to this zone',
                    ),
                    trailing: const Chip(
                      label: Text('Online'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  Future<List<NodeModel>> _getAllNodes() async {
    final farm = await mockFarmRepository.getFarm();
    final fields = await mockFarmRepository.getFields(farm.id);

    final List<NodeModel> allNodes = [];

    for (final field in fields) {
      final zones = await mockFarmRepository.getZones(field.id);

      for (final zone in zones) {
        final nodes = await mockFarmRepository.getNodes(zone.id);
        allNodes.addAll(nodes);
      }
    }

    return allNodes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
      ),
      body: FutureBuilder<List<NodeModel>>(
        future: _getAllNodes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingScreen();
          }

          if (snapshot.hasError) {
            return const _ErrorScreen(
              message: 'Unable to load sensor nodes.',
            );
          }

          final nodes = snapshot.data ?? [];

          if (nodes.isEmpty) {
            return const _ErrorScreen(
              message: 'No sensor nodes found.',
            );
          }

          final onlineCount =
              nodes.where((node) => node.isOnline).length;

          final offlineCount =
              nodes.where((node) => !node.isOnline).length;

          return RefreshIndicator(
            onRefresh: () async {
              await _getAllNodes();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Field Sensors',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor the health and latest readings of your nodes.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        title: 'Total Nodes',
                        value: '${nodes.length}',
                        subtitle: 'Registered', status: '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        title: 'Online',
                        value: '$onlineCount',
                        subtitle: 'Connected', status: '',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _InfoCard(
                  title: 'Offline',
                  value: '$offlineCount',
                  subtitle: 'Needs attention', status: '',
                ),

                const SizedBox(height: 24),

                Text(
                  'All Nodes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),

                ...nodes.map(
                      (node) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          node.isOnline
                              ? Icons.sensors
                              : Icons.sensors_off,
                        ),
                      ),
                      title: Text(
                        node.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Soil moisture: '
                            '${node.soilMoisture.toStringAsFixed(0)}% • '
                            '${node.temperature.toStringAsFixed(0)}°C',
                      ),
                      trailing: Chip(
                        label: Text(
                          node.isOnline ? 'Online' : 'Offline',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SensorDetailsScreen(
                              nodeId: node.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SimpleNavigationScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_NavigationCardData> cards;
  final Widget? extraContent;

  const _SimpleNavigationScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.cards = const [],
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF7FAF5),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF239447),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF526B70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...cards.map(
                (card) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _NavigationCard(
                icon: card.icon,
                title: card.title,
                subtitle: card.subtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => card.destination,
                    ),
                  );
                },
              ),
            ),
          ),
          if (extraContent != null) extraContent!,
        ],
      ),
    );
  }
}

class _NavigationCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget destination;

  const _NavigationCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE3EAE4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4EA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF239447),
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade500,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _FarmStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _FarmStatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF239447),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF073D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF526B70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _NodeStatusCard extends StatelessWidget {
  final bool isOnline;
  final String lastUpdated;
  final String zoneId;

  const _NodeStatusCard({
    required this.isOnline,
    required this.lastUpdated,
    required this.zoneId,
  });

  @override
  Widget build(BuildContext context) {
    final bool online = isOnline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: online
                  ? const Color(0xFFE8F4EA)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.sensors_rounded,
              color: online
                  ? const Color(0xFF239447)
                  : const Color(0xFF7A8587),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone $zoneId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  lastUpdated,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: online
                  ? const Color(0xFFE8F4EA)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              online ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: online
                    ? const Color(0xFF239447)
                    : const Color(0xFF667276),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String status;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasStatus = status.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF073D32),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (hasStatus) ...[
            const SizedBox(height: 8),
            Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF239447),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4EA),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF239447),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FAF5),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF239447),
          ),
        ),
      ),
    );
  }
}
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({
    this.message = 'Unable to load data.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE3EAE4),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD95C5C),
                    size: 25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}