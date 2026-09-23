import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_history_screen.dart';
import '../../core/app_colors.dart';
import '../../data/models/ai_result_model.dart';
import '../../data/repositories/ai_history_repository.dart';
import '../../data/repositories/repository_provider.dart';
import '../../data/services/ai_service.dart';
import 'ai_result_screen.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final AiService _aiService = AiService();
  final AiHistoryRepository _aiHistoryRepository =
      aiHistoryRepository;

  File? _selectedImage;

  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAi();
  }

  Future<void> _initializeAi() async {
    try {
      await _aiService.initialize();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to initialize AI analysis.';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedImage == null) return;

      setState(() {
        _selectedImage = File(pickedImage.path);
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to select the image.';
      });
    }
  }

  Future<void> _analyzeCrop() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final prediction = await _aiService.analyzeImage(
        _selectedImage!.path,
      );

      final result = AiResultModel(
        prediction: prediction.prediction,
        confidence: prediction.confidence,
        explanation:
        'The AI model identified visual patterns in the submitted crop image that match this possible crop-health issue.',
        recommendation:
        'Verify the crop condition in the field and follow the recommended crop-care guidance before taking action.',
        timestamp: DateTime.now(),
      );

      // Save the completed analysis to local history.
      await _aiHistoryRepository.saveAnalysis(result);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiResultScreen(
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
        'AI analysis could not be completed. Please try another image.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'AI History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AiHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildImageArea(),
            const SizedBox(height: 18),
            _buildImageButtons(),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              _buildErrorCard(),
              const SizedBox(height: 18),
            ],
            _buildAnalyzeButton(),
            const SizedBox(height: 18),
            _buildAdvisoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check your crop health',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Take a clear photo of a crop leaf or plant and let the AI model analyze it.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea() {
    return Container(
      width: double.infinity,
      height: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDE7E0),
        ),
      ),
      child: _selectedImage == null
          ? _buildEmptyImageState()
          : ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildEmptyImageState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EC),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.eco_outlined,
            color: AppColors.accentGreen,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No crop image selected',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 7),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Choose a clear crop image from your camera or gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing
                ? null
                : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Camera'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(
                color: AppColors.accentGreen,
              ),
              foregroundColor: AppColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing
                ? null
                : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(
                color: AppColors.accentGreen,
              ),
              foregroundColor: AppColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _selectedImage == null || _isAnalyzing
            ? null
            : _analyzeCrop,
        icon: _isAnalyzing
            ? const SizedBox(
          width: 19,
          height: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.auto_awesome),
        label: Text(
          _isAnalyzing ? 'Analyzing Crop...' : 'Analyze Crop',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1C7C3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFB42318),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF8A1C13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'For the clearest analysis, use a well-lit photo where the crop leaf is clearly visible. AI results are advisory and should be verified in the field.',
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
}