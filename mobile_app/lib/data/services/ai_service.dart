import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AiPrediction {
  final String prediction;
  final double confidence;

  const AiPrediction({
    required this.prediction,
    required this.confidence,
  });
}

class AiService {
  static const String _modelPath =
      'assets/ai/krishisense_tomato_final.tflite';

  static const String _labelsPath =
      'assets/ai/krishisense_tomato_classes.txt';

  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> initialize() async {
    if (_interpreter != null && _labels != null) {
      return;
    }

    _interpreter = await Interpreter.fromAsset(_modelPath);

    final labelsText = await rootBundle.loadString(_labelsPath);

    _labels = labelsText
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();

    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);

    print(' AI MODEL LOADED SUCCESSFULLY ');
    print('Input shape: ${inputTensor.shape}');
    print('Input type: ${inputTensor.type}');
    print('Output shape: ${outputTensor.shape}');
    print('Output type: ${outputTensor.type}');
    print('Labels: ${_labels!.length}');
  }

  Future<AiPrediction> analyzeImage(String imagePath) async {
    await initialize();

    final interpreter = _interpreter!;
    final labels = _labels!;

    final imageFile = File(imagePath);

    if (!await imageFile.exists()) {
      throw Exception('Selected image could not be found.');
    }

    final imageBytes = await imageFile.readAsBytes();

    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Unable to decode the selected image.');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: _inputSize,
      height: _inputSize,
    );

    double redTotal = 0;
    double greenTotal = 0;
    double blueTotal = 0;

    for (var y = 0; y < resizedImage.height; y++) {
      for (var x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);

        redTotal += pixel.r;
        greenTotal += pixel.g;
        blueTotal += pixel.b;
      }
    }

    final pixelCount = resizedImage.width * resizedImage.height;

    print('===== IMAGE DEBUG =====');
    print('Image size: ${decodedImage.width} x ${decodedImage.height}');
    print('Average R: ${redTotal / pixelCount}');
    print('Average G: ${greenTotal / pixelCount}');
    print('Average B: ${blueTotal / pixelCount}');
    print('=======================');

    final input = _createInputTensor(resizedImage);

    final output = [
      List<double>.filled(labels.length, 0.0),
    ];

    interpreter.run(input, output);

    final probabilities = output[0];

    print('===== AI RAW PREDICTIONS =====');

    for (var i = 0; i < probabilities.length; i++) {
      print('${labels[i]} : ${probabilities[i]}');
    }

    print('==============================');

    if (probabilities.isEmpty) {
      throw Exception('AI model returned no predictions.');
    }

    var bestIndex = 0;

    for (var i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[bestIndex]) {
        bestIndex = i;
      }
    }

    return AiPrediction(
      prediction: labels[bestIndex],
      confidence: probabilities[bestIndex],
    );
  }

  List<List<List<List<double>>>> _createInputTensor(
      img.Image image,
      ) {
    return [
      List.generate(
        _inputSize,
            (y) => List.generate(
          _inputSize,
              (x) {
            final pixel = image.getPixel(x, y);

            final red = pixel.r.toDouble();
            final green = pixel.g.toDouble();
            final blue = pixel.b.toDouble();

            return [
              red,
              green,
              blue,
            ];
          },
        ),
      ),
    ];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}