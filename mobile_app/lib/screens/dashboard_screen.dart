import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../data/models/ai_result_model.dart';
import '../data/models/node_model.dart';
import '../data/models/recommendation_model.dart';
import '../data/repositories/repository_provider.dart';
import 'main/ai_analysis_screen.dart';
import 'main/alerts_screen.dart';
import 'main/irrigation_screen.dart';
import 'main/recommendation_screen.dart';
import 'main/ai_result_screen.dart';
import 'main/main_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  Future<_DashboardData> _loadDashboardData() async {
    final farm = await mockFarmRepository.getFarm();

    final fields = await mockFarmRepository.getFields(farm.id);

    final List<NodeModel> nodes = [];

    for (final field in fields) {
      final zones = await mockFarmRepository.getZones(field.id);

      for (final zone in zones) {
        final zoneNodes = await mockFarmRepository.getNodes(zone.id);
        nodes.addAll(zoneNodes);
      }
    }

    final recommendations = await mockFarmRepository.getRecommendations();

    final aiResults = await mockFarmRepository.getAiResults();

    return _DashboardData(
      farmName: farm.name,
      location: farm.location,
      fieldsCount: fields.length,
      nodes: nodes,
      recommendations: recommendations,
      aiResults: aiResults,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _DashboardLoading();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const _DashboardError();
          }

          final data = snapshot.data!;

          final onlineNodes = data.nodes.where((node) => node.isOnline).length;

          final offlineNodes =
              data.nodes.where((node) => !node.isOnline).length;

          final averageMoisture = data.nodes.isEmpty
              ? 0.0
              : data.nodes
                      .map((node) => node.soilMoisture)
                      .reduce((a, b) => a + b) /
                  data.nodes.length;

          final moistureProgress = (averageMoisture / 100).clamp(0.0, 1.0);

          final latestRecommendation = data.recommendations.isNotEmpty
              ? data.recommendations.first
              : null;

          final latestAiResult =
              data.aiResults.isNotEmpty ? data.aiResults.first : null;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/header_landscape.png',
                  height: 285,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 285,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        AppColors.background.withOpacity(0.98),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        12,
                        0,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/krishisense_logo.png',
                            height: 44,
                            width: 44,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.appName,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                Text(
                                  l10n.tagline,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9F8DE),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AlertsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_none,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            _dashboardFuture = _loadDashboardData();
                          });

                          await _dashboardFuture;
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            38,
                            20,
                            30,
                          ),
                          children: [
                            Text(
                              l10n.goodEveningFarmer,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              l10n.farmStatusMessage,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // FARM OVERVIEW
                            _DashboardFarmCard(
                              farmName: data.farmName,
                              location: data.location,
                              fieldsCount: data.fieldsCount,
                              nodesCount: data.nodes.length,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FarmScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // SOIL MOISTURE
                            _SoilMoistureCard(
                              moisture: averageMoisture,
                              progress: moistureProgress,
                              onlineNodes: onlineNodes,
                              offlineNodes: offlineNodes,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SensorsScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            // AI CROP ANALYSIS
                            _FeatureCard(
                              icon: Icons.eco_outlined,
                              iconBackground: const Color(0xFFE8F4EA),
                              iconColor: const Color(0xFF239447),
                              title: 'AI Crop Analysis',
                              subtitle:
                                  'Check your crop health using AI-assisted analysis.',
                              trailing: latestAiResult == null
                                  ? 'Analyze'
                                  : latestAiResult.prediction,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AiAnalysisScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // RECOMMENDATION
                            _FeatureCard(
                              icon: Icons.lightbulb_outline,
                              iconBackground: const Color(0xFFFFF3DD),
                              iconColor: const Color(0xFFB45F06),
                              title: 'Recommendation',
                              subtitle: latestRecommendation == null
                                  ? 'No recommendation available.'
                                  : latestRecommendation.message,
                              trailing: latestRecommendation == null
                                  ? ''
                                  : latestRecommendation.action,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RecommendationScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // ALERTS
                            _FeatureCard(
                              icon: offlineNodes > 0
                                  ? Icons.warning_amber_outlined
                                  : Icons.notifications_none,
                              iconBackground: offlineNodes > 0
                                  ? const Color(0xFFFFF3DD)
                                  : const Color(0xFFE8F4EA),
                              iconColor: offlineNodes > 0
                                  ? const Color(0xFFB45F06)
                                  : const Color(0xFF239447),
                              title: 'Alerts',
                              subtitle: offlineNodes > 0
                                  ? '$offlineNodes sensor node${offlineNodes == 1 ? '' : 's'} need attention.'
                                  : 'No critical sensor alerts right now.',
                              trailing:
                                  offlineNodes > 0 ? 'Attention' : 'All clear',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AlertsScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // IRRIGATION
                            _FeatureCard(
                              icon: Icons.water_drop_outlined,
                              iconBackground: const Color(0xFFE5F4F7),
                              iconColor: const Color(0xFF16758A),
                              title: 'Irrigation',
                              subtitle: latestRecommendation == null
                                  ? 'View current irrigation status.'
                                  : latestRecommendation.action,
                              trailing: 'View status',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IrrigationScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 22),

                            // QUICK STATUS
                            Text(
                              'Farm Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStatusCard(
                                    icon: Icons.sensors,
                                    title: 'Online',
                                    value: '$onlineNodes',
                                    subtitle: 'Nodes',
                                    color: const Color(0xFF239447),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MiniStatusCard(
                                    icon: Icons.sensors_off,
                                    title: 'Offline',
                                    value: '$offlineNodes',
                                    subtitle: 'Nodes',
                                    color: const Color(0xFFB45F06),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardData {
  final String farmName;
  final String location;
  final int fieldsCount;
  final List<NodeModel> nodes;
  final List<RecommendationModel> recommendations;
  final List<AiResultModel> aiResults;

  const _DashboardData({
    required this.farmName,
    required this.location,
    required this.fieldsCount,
    required this.nodes,
    required this.recommendations,
    required this.aiResults,
  });
}

class _DashboardFarmCard extends StatelessWidget {
  final String farmName;
  final String location;
  final int fieldsCount;
  final int nodesCount;
  final VoidCallback onTap;

  const _DashboardFarmCard({
    required this.farmName,
    required this.location,
    required this.fieldsCount,
    required this.nodesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 172,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/farm_hero.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.94),
                          AppColors.primaryGreen.withOpacity(0.55),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.0,
                          0.48,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 72,
                          width: 72,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farmName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white70,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '$fieldsCount fields • $nodesCount nodes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoilMoistureCard extends StatelessWidget {
  final double moisture;
  final double progress;
  final int onlineNodes;
  final int offlineNodes;
  final VoidCallback onTap;

  const _SoilMoistureCard({
    required this.moisture,
    required this.progress,
    required this.onlineNodes,
    required this.offlineNodes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final moistureText = '${moisture.toStringAsFixed(0)}%';

    final status = moisture >= 40 && moisture <= 80
        ? 'Optimal'
        : moisture < 40
            ? 'Low'
            : 'High';

    final statusColor =
        status == 'Optimal' ? const Color(0xFF239447) : const Color(0xFFB45F06);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FAF1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0EDE2),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                height: 108,
                width: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 108,
                      width: 108,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFFD8EBDD),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF239447),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          moistureText,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Text(
                          'Moisture',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soil Moisture',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'Optimal'
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$onlineNodes online • $offlineNodes offline',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Latest sensor readings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A9A96),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
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
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 88,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
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
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                        height: 1.3,
                      ),
                    ),
                    if (trailing.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        trailing,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF8A9A96),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _MiniStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 78,
      ),
      padding: const EdgeInsets.all(14),
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
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$value $subtitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
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

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.accentGreen,
          ),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    Icons.cloud_off_outlined,
                    color: Color(0xFFD95C5C),
                    size: 25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Unable to load farm dashboard',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Please check the connection and try again.',
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
