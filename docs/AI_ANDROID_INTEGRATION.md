# KrishiSense AI → Android Integration Contract

## 1. Purpose

This document defines the fixed interface between the KrishiSense on-device AI model and the Android mobile application.

The Android application will run crop-health image inference locally using the TensorFlow Lite model.

Internet connectivity is not required for model inference.

## 2. Model

Model file:

krishisense_tomato_final.tflite

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

The output class order is fixed and must not be changed.

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

The expected pipeline is:

Camera/Gallery Image
↓
Image Resize
↓
224 × 224
↓
RGB Conversion
↓
Float32 Conversion
↓
MobileNetV2 Preprocessing
↓
TFLite Model
↓
10-Class Probability Output
↓
Highest Probability Class
↓
Confidence
↓
Recommendation

## 5. Image Preprocessing

The Android implementation must:

1. Load the selected image.
2. Resize it to 224 × 224 pixels.
3. Convert the image to RGB.
4. Convert pixel values to float32.
5. Apply MobileNetV2 preprocessing.

MobileNetV2 preprocessing:

pixel = (pixel / 127.5) - 1.0

The same preprocessing used during model training must be used during Android inference.

## 6. Model Output

The model produces 10 probability values.

The highest probability determines the predicted class.

Example:

Prediction: early_blight

Confidence: 87%

Confidence should be displayed as a percentage.

## 7. User-Friendly Class Names

The raw model class names should not be shown directly to farmers.

bacterial_spot → Bacterial Spot

early_blight → Early Blight

healthy → Healthy

late_blight → Late Blight

leaf_mold → Leaf Mold

septoria_leaf_spot → Septoria Leaf Spot

spider_mites_two_spotted_spider_mite → Spider Mites

target_spot → Target Spot

tomato_mosaic_virus → Tomato Mosaic Virus

tomato_yellow_leaf_curl_virus → Tomato Yellow Leaf Curl Virus

## 8. Confidence Handling

The Android app must display the model confidence along with the prediction.

Example:

Prediction: Late Blight
Confidence: 91%

Confidence should not be treated as absolute certainty.

Recommended interpretation:

- High confidence: show the prediction normally.
- Medium confidence: show the prediction with an uncertainty notice.
- Low confidence: ask the farmer to capture another clear image.

Suggested low-confidence message:

"AI confidence is low. Please capture a clearer image of the affected leaf."

The exact confidence thresholds can be configured during implementation and must be documented.

## 9. Recommendation Mapping

The Android app should map the predicted class to a simple farmer-friendly recommendation.

Example:

Early Blight:
"Remove severely affected leaves and follow recommended crop-protection practices. Consult local agricultural guidance before applying pesticides."

Late Blight:
"Remove severely affected plant material and monitor nearby plants. Follow locally recommended disease-control practices."

Bacterial Spot:
"Remove heavily affected leaves and avoid unnecessary leaf wetness. Follow recommended crop-protection practices."

Healthy:
"No major visual issue detected by the AI model. Continue regular crop monitoring."

For other classes, recommendations should be added using the same structure.

Recommendations are advisory and must not be presented as guaranteed cures.

## 10. AI Result Object

The Android AI module should return a structured result.

Example:

{
    "prediction": "early_blight",
    "displayName": "Early Blight",
    "confidence": 0.87,
    "confidencePercent": 87,
    "recommendation": "Remove severely affected leaves and monitor the crop.",
    "isLowConfidence": false
}

The UI should use this result to display the AI analysis screen.

## 11. Offline Requirement

The TFLite model must be packaged with the Android application.

The model must not be downloaded from the internet during inference.

Required flow:

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

Internet connectivity is therefore not required for the AI inference itself.

Backend communication may still require internet depending on the feature being used.

## 12. Current Implementation Boundary

The AI module is responsible for:

- Loading the TFLite model.
- Loading class labels.
- Image preprocessing.
- Running TFLite inference.
- Finding the highest-probability class.
- Calculating/displaying confidence.
- Returning the structured AI result.

The AI module is NOT responsible for:

- Android UI design.
- Database management.
- ESP32 communication.
- Pump control.
- General backend functionality.

The Android UI should consume the AI result through a clean interface.

## 13. Android Model File Location

The TFLite model should be packaged inside the Android application.

Recommended location:

mobile_app/app/src/main/assets/krishisense_tomato_final.tflite

The class-label file should also be packaged with the application:

mobile_app/app/src/main/assets/krishisense_tomato_classes.txt

The Android application must load both files locally.

## 14. Model Loading

The Android application should:

1. Load the TFLite model from the assets folder.
2. Create the TFLite interpreter.
3. Load the class labels.
4. Prepare the input tensor.
5. Run inference.
6. Read the output tensor.
7. Find the class with the highest probability.
8. Return the prediction and confidence.

The model should be loaded efficiently and reused rather than recreated for every image.

## 15. Error Handling

The AI module must safely handle:

- Missing model file.
- Missing label file.
- Invalid image.
- Unsupported image format.
- Image preprocessing failure.
- TFLite interpreter errors.
- Empty model output.

The app should show a user-friendly error instead of crashing.

Example:

"Unable to analyze this image. Please try again."

## 16. Testing Requirements

Before considering AI → Android integration complete, test:

1. A known test image.
2. A healthy tomato leaf.
3. Multiple disease images.
4. A low-quality image.
5. An unrelated image.
6. The app with internet disabled.

The prediction and confidence should be displayed correctly.

The offline test must confirm that the model can perform inference without an internet connection.

## 17. Verified Model Information

Current verified model:

Model:
KrishiSense Tomato MobileNetV2

Model format:
TensorFlow Lite

Input:
224 × 224 × 3 float32

Output:
10-class float32 probability vector

Model size:
Approximately 8.5 MB

Held-out test accuracy:
91.93%

Keras vs TFLite prediction match:
100%

These metrics were measured on the project's held-out tomato test dataset.

They should not be presented as guaranteed real-world field accuracy.

## 18. Prototype Scope

The current SIH prototype focuses on tomato crop-health analysis.

The model currently supports 10 tomato classes.

Multi-crop AI support is a future scalability direction and is not part of the current trained model.

The Android implementation must therefore use the current tomato model without changing its class order or input specification.

## 19. Integration Completion Criteria

AI → Android integration is considered complete when:

- [ ] TFLite model is inside the Android project.
- [ ] Class-label file is inside the Android project.
- [ ] TFLite interpreter loads successfully.
- [ ] Camera/gallery image can be selected.
- [ ] Image is resized to 224 × 224.
- [ ] Correct preprocessing is applied.
- [ ] Inference runs successfully.
- [ ] Prediction is displayed.
- [ ] Confidence is displayed.
- [ ] Recommendation is displayed.
- [ ] Invalid input is handled safely.
- [ ] Inference works with internet disabled.

## 20. Important Rule

Do not modify the trained model, class order, input size, or preprocessing without coordinating with the AI/ML owner.

Any change to the AI interface must be documented in this file and communicated to the Android developer.

This document defines the current AI → Android integration contract for the KrishiSense SIH26180 prototype.