# KrishiSense AI Model

## Purpose

KrishiSense uses on-device AI for assisted crop/leaf image analysis. The current validated model is a tomato classifier intended to provide a prediction, confidence score and advisory interpretation.

AI output is **AI-assisted and advisory**, not a guaranteed field diagnosis.

## Current Model

- Architecture: **MobileNetV2 transfer learning**
- Input: **224 × 224 × 3**
- Input type: **float32**
- Output: **10-class softmax**
- Deployment format: **TensorFlow Lite**
- Current file: `krishisense_tomato_final.tflite`
- Inference location: **Android device / Flutter application**
- Inference does not require a backend AI call.

### Classes

```text
0  bacterial_spot
1  early_blight
2  healthy
3  late_blight
4  leaf_mold
5  septoria_leaf_spot
6  spider_mites_two_spotted_spider_mite
7  target_spot
8  tomato_mosaic_virus
9  tomato_yellow_leaf_curl_virus
```

## Verified Evaluation

The final model was evaluated on a held-out test set of **1,821 images**.

- Keras test accuracy: **91.93%**
- TFLite test accuracy: **91.93%**
- Keras vs TFLite prediction match: **100%**

The model is strongest on several well-represented classes, while **early blight recall is lower** than the overall accuracy. This limitation must be considered when interpreting predictions.

## Preprocessing

The current exported TFLite graph contains its training preprocessing. Therefore the Flutter application passes **raw RGB pixel values in the 0–255 range** after resizing to 224 × 224.

Do not additionally apply:

- `/255`
- `/127.5 - 1`
- ImageNet normalization
- BGR channel swapping

Double preprocessing was previously shown to change predictions substantially.

## Current AI Flow

```text
Camera Image
     ↓
Flutter
     ↓
Resize 224×224
     ↓
Raw RGB → TFLite
     ↓
10-class prediction
     ↓
Confidence
     ↓
Advisory result / explanation
```

## Dataset / Training

The current tomato model was trained using a cleaned tomato subset derived from PlantVillage. The selected image set used the `color/images` variant, with an 80/10/10 train/validation/test split.

Training used:

- TensorFlow
- MobileNetV2 ImageNet initialization
- augmentation
- class weighting
- transfer learning followed by fine-tuning

The dataset source/license and exact training notebook should be kept with the AI training artifacts when those artifacts are committed or documented.

## Limitations

- Current validated scope is **tomato**.
- Dataset performance does not guarantee equal performance on arbitrary field photographs.
- Lighting, camera quality, background, leaf angle and unseen conditions can affect predictions.
- Softmax confidence is not a guarantee of correctness.
- Low-confidence or ambiguous cases should be treated as uncertain.
- Multi-crop and stronger field-generalization work remains future development.

## Future AI Direction

Future versions can add real-world field images, additional crops, uncertainty/rejection handling, calibrated confidence thresholds and field-specific validation.

## Ownership

Tanishq owns the AI implementation under `/ai/`. Tanush owns mobile inference integration and result presentation. Ninad owns any backend API/storage used to persist AI results.
