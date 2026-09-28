# KrishiSense AI → Android Integration Contract

## 1. Purpose

This document defines the fixed interface between the KrishiSense on-device AI model and the Flutter Android application.

The Android application runs crop-health image inference locally using TensorFlow Lite. Internet connectivity is not required for model inference.

## 2. Model

Model file:

`krishisense_tomato_final.tflite`

Model type:

MobileNetV2-based tomato crop-health classification model.

Model size:

Approximately 8.5 MB.

Input image size:

224 × 224 pixels.

Input datatype:

float32.

Output:

10-class probability vector.

## 3. Supported Tomato Classes

The output class order is fixed:

0 - bacterial_spot  
1 - early_blight  
2 - healthy  
3 - late_blight  
4 - leaf_mold  
5 - septoria_leaf_spot  
6 - spider_mites_two_spotted_spider_mite  
7 - target_spot  
8 - tomato_mosaic_virus  
9 - tomato_yellow_leaf_curl_virus

## 4. Inference Pipeline

```text
Camera / Gallery Image
        ↓
Image Decode
        ↓
Resize to 224 × 224
        ↓
RGB Conversion
        ↓
Float32 Conversion
        ↓
RAW RGB 0–255 input
        ↓
TFLite Model
        ↓
10-Class Probability Output
        ↓
Highest Probability Class
        ↓
Confidence
        ↓
Recommendation / Explanation
```

## 5. Critical Preprocessing Rule

The current exported TFLite graph already contains the preprocessing used by the trained model.

Therefore the Flutter application must pass **raw RGB pixel values in the 0–255 range** after resizing to 224 × 224.

Do **not** additionally apply:

- `pixel / 255`
- `(pixel / 127.5) - 1.0`
- ImageNet normalization
- BGR channel swapping

Double preprocessing was experimentally verified to change model predictions substantially.

## 6. Model Output

The model produces 10 probability values.

The highest probability determines the predicted class.

Example:

```text
Prediction: early_blight
Confidence: 87%
```

Confidence should be displayed as a percentage, while making clear that model confidence is not absolute certainty.

## 7. User-Friendly Class Names

The raw model class names should not be shown directly to farmers.

- bacterial_spot → Bacterial Spot
- early_blight → Early Blight
- healthy → Healthy
- late_blight → Late Blight
- leaf_mold → Leaf Mold
- septoria_leaf_spot → Septoria Leaf Spot
- spider_mites_two_spotted_spider_mite → Spider Mites
- target_spot → Target Spot
- tomato_mosaic_virus → Tomato Mosaic Virus
- tomato_yellow_leaf_curl_virus → Tomato Yellow Leaf Curl Virus

## 8. Confidence Handling

The Android app should display model confidence with the prediction.

Confidence should not be treated as absolute certainty.

The UI may use configured thresholds to distinguish high-, medium- and low-confidence results. Low-confidence or ambiguous results should encourage the farmer to capture a clearer image or seek appropriate crop-management guidance.

Suggested message:

```text
AI confidence is low. Please capture a clearer image of the affected leaf.
```

Thresholds must be documented when finalized.

## 9. Recommendation Mapping

Recommendations should be farmer-friendly and advisory.

Example:

```text
Prediction: Early Blight

Recommendation:
Remove severely affected leaves and follow recommended crop-protection
practices. Consult local agricultural guidance before applying pesticides.
```

Recommendations are not guaranteed cures or guaranteed diagnoses.

## 10. AI Result Object

The Android AI module should return a structured result such as:

```json
{
  "prediction": "early_blight",
  "displayName": "Early Blight",
  "confidence": 0.87,
  "confidencePercent": 87,
  "recommendation": "Remove severely affected leaves and monitor the crop.",
  "isLowConfidence": false
}
```

## 11. Offline Requirement

The TFLite model is packaged with the Android application.

Required flow:

```text
Android App
   ↓
Local TFLite Model
   ↓
Local Inference
   ↓
Prediction
   ↓
Confidence
   ↓
Recommendation
```

Internet connectivity is therefore not required for AI inference.

Backend communication may still require connectivity for sensor data, stored results, recommendations or other server-backed features.

## 12. Current Implementation Boundary

The AI/mobile inference layer is responsible for:

- Loading the TFLite model.
- Loading class labels.
- Image preprocessing.
- Running TFLite inference.
- Finding the highest-probability class.
- Calculating/displaying confidence.
- Returning the structured AI result.

It is **not** responsible for:

- ESP32 communication.
- Pump control.
- General backend functionality.
- Database ownership.

The mobile UI consumes the local AI result.

## 13. Model File Location

The model and class-label file should be packaged inside the Android application according to the Flutter project's asset configuration.

The expected assets are:

```text
krishisense_tomato_final.tflite
krishisense_tomato_classes.txt
```

The application must load both files locally.

## 14. Error Handling

The AI module must safely handle:

- Missing model file
- Missing label file
- Invalid image
- Unsupported image format
- Image preprocessing failure
- TFLite interpreter errors
- Empty model output

The app should show a user-friendly error instead of crashing.

## 15. Testing Requirements

Test at minimum:

1. Known held-out tomato image.
2. Healthy tomato leaf.
3. Multiple disease images.
4. Low-quality image.
5. Unrelated/out-of-scope image.
6. AI inference with internet disabled.

The model should be validated on known test data and should not be described as guaranteed real-world field accuracy.

## 16. Verified Model Information

Current verified model:

- Model: KrishiSense Tomato MobileNetV2
- Format: TensorFlow Lite
- Input: 224 × 224 × 3 float32
- Output: 10-class float32 probability vector
- Size: approximately 8.5 MB
- Held-out test accuracy: **91.93%**
- Keras vs TFLite prediction match: **100%**

These metrics were measured on the project's held-out tomato test dataset.

## 17. Prototype Scope

The current SIH prototype focuses on tomato crop-health analysis.

The model supports 10 tomato classes.

Multi-crop AI is a future scalability direction and is not part of the current trained model.

## 18. Integration Completion Criteria

AI → Android integration is complete when:

- [ ] TFLite model is packaged in the Flutter app.
- [ ] Class-label file is packaged.
- [ ] Interpreter loads successfully.
- [ ] Camera/gallery image can be selected.
- [ ] Image is resized to 224 × 224.
- [ ] RGB input is passed as raw 0–255 float32 values.
- [ ] Inference runs successfully.
- [ ] Prediction is displayed.
- [ ] Confidence is displayed.
- [ ] Recommendation is displayed.
- [ ] Invalid input is handled safely.
- [ ] Inference works with internet disabled.

## 19. Important Rule

Do not modify the trained model, class order, input size or preprocessing without coordinating with the AI/ML owner.

Any change to the AI interface must be documented here and communicated to the mobile developer.

This document defines the current AI → Android integration contract for the KrishiSense SIH26180 prototype.
