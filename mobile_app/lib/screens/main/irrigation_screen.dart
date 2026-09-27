import 'package:flutter/material.dart';

import '../../data/models/decision_result_model.dart';
import '../../data/services/decision_service.dart';

class IrrigationScreen extends StatefulWidget {
  final String? zoneId;
  final String? accessToken;
  final String crop;
  final String growthStage;
  final String baseUrl;

  const IrrigationScreen({
    super.key,
    this.zoneId,
    this.accessToken,
    this.crop = 'tomato',
    this.growthStage = 'flowering',
    this.baseUrl = 'http://127.0.0.1:8000',
  });

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  DecisionResultModel? _decision;
  String? _error;
  bool _loading = false;

  Future<void> _checkDecision() async {
    final zoneId = widget.zoneId;

    if (zoneId == null || zoneId.isEmpty) {
      setState(() {
        _decision = null;
        _error = 'No zone is connected to this irrigation view.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await DecisionService(
        baseUrl: widget.baseUrl,
        accessToken: widget.accessToken,
      ).evaluate(
        zoneId: zoneId,
        crop: widget.crop,
        growthStage: widget.growthStage,
      );

      if (!mounted) return;

      setState(() {
        _decision = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _decision = null;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

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
              child: _buildDecisionCard(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _checkDecision,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'Checking...' : 'Check Decision'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Irrigation Control',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F4EA),
                child: Icon(
                  Icons.settings_remote_outlined,
                  color: Color(0xFF239447),
                ),
              ),
              title: const Text(
                'Backend-Controlled',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'The mobile app requests decisions from the backend. It does not communicate directly with the pump or ESP32.',
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
                      'Decision logic stays in the backend. Hardware actuation will be connected through the backend and hardware integration layer.',
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

  Widget _buildDecisionCard() {
    if (_loading) {
      return const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('Requesting the latest irrigation decision...'),
          ),
        ],
      );
    }

    if (_error != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFC94A4A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_error!),
          ),
        ],
      );
    }

    final decision = _decision;

    if (decision == null) {
      return Text(
        'Check the latest irrigation decision from the backend.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final irrigate = decision.decision == 'IRRIGATE';
    final insufficient = decision.decision == 'INSUFFICIENT_DATA';

    final icon = irrigate
        ? Icons.water_drop
        : insufficient
            ? Icons.help_outline
            : Icons.check_circle_outline;

    final iconColor = irrigate
        ? const Color(0xFFC94A4A)
        : insufficient
            ? const Color(0xFF9A6A00)
            : const Color(0xFF239447);

    final backgroundColor = irrigate
        ? const Color(0xFFFFE7E7)
        : insufficient
            ? const Color(0xFFFFF3DD)
            : const Color(0xFFE8F4EA);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                decision.decision,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Priority: ${decision.priority}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                decision.reason,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
