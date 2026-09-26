import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/ai_result_model.dart';
import '../../data/repositories/repository_provider.dart';

class AiResultScreen extends StatelessWidget {
  final AiResultModel? result;

  const AiResultScreen({
    super.key,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      return _ResultContent(result: result!);
    }

    return FutureBuilder<List<AiResultModel>>(
      future: mockFarmRepository.getAiResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Crop Analysis'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Crop Analysis'),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No AI analysis result is available yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _ResultContent(
          result: snapshot.data!.first,
        );
      },
    );
  }
}

class _ResultContent extends StatelessWidget {
  final AiResultModel result;

  const _ResultContent({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = result.confidence.clamp(0.0, 1.0);
    final confidencePercent = confidence * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHero(
              context,
              confidencePercent,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'Confidence',
            ),

            const SizedBox(height: 10),

            _buildConfidenceCard(
              context,
              confidence,
              confidencePercent,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'What the AI found',
            ),

            const SizedBox(height: 10),

            _buildInformationCard(
              icon: Icons.visibility_outlined,
              iconColor: AppColors.accentGreen,
              backgroundColor: const Color(0xFFEAF5EC),
              title: 'AI-assisted observation',
              content: result.explanation,
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'Recommended Action',
            ),

            const SizedBox(height: 10),

            _buildRecommendationCard(),

            const SizedBox(height: 24),

            _buildAdvisoryCard(),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Analysis recorded ${_formatDate(result.timestamp)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHero(
      BuildContext context,
      double confidencePercent,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE5F3E8),
            Color(0xFFF2F8F2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD5E8D9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: AppColors.accentGreen,
                  size: 28,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 15,
                      color: AppColors.accentGreen,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI Analysis',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            'Possible crop-health issue',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 6),

          Text(
            _formatPrediction(result.prediction),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'AI-assisted analysis based on the submitted crop image.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 17,
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: 7),
              Text(
                '${confidencePercent.toStringAsFixed(0)}% model confidence',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildConfidenceCard(
      BuildContext context,
      double confidence,
      double confidencePercent,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Model confidence',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '${confidencePercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 11,
              backgroundColor: const Color(0xFFE6EDE8),
              color: AppColors.accentGreen,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Confidence indicates how strongly the model matched this prediction. '
                'It is not a guaranteed diagnosis.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EAE5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFD6E9D9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.accentGreen,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggested next step',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  result.recommendation,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF0DFB2),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF9A6A00),
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'This is an AI-assisted advisory result. '
                  'Verify the crop condition in the field before taking major crop-care action.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF705500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrediction(String prediction) {
    return prediction
        .split('_')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year at $hour:$minute $period';
  }
}