# KrishiSense AI Model

## Purpose
AI provides assisted crop/leaf image analysis and returns a prediction with confidence and an advisory recommendation.

## Fixed Interface

```text
Image → Preprocessing → Model → Prediction + Confidence → Backend → Mobile App
```

## Prototype Requirements
The AI implementation must document:
- dataset/source and license
- selected crop/classes
- preprocessing
- train/validation/test split
- evaluation metrics
- sample predictions
- limitations
- deployment format if edge inference is actually implemented

## Safety / Accuracy Wording
AI output is advisory and must not be described as a guaranteed disease diagnosis. Low-confidence results should be treated as uncertain and should encourage inspection/appropriate expert guidance.

## Ownership
Tanishq owns the AI implementation under `/ai/`. Ninad owns the backend interface and storage. Tanush owns the mobile presentation of the result.
