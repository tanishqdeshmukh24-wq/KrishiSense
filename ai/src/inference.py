"""
KrishiSense AI Inference Module

Runs tomato crop/leaf image classification using the verified
KrishiSense TensorFlow Lite model.
"""

from pathlib import Path

import numpy as np
from PIL import Image
import tensorflow as tf


BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "models" / "krishisense_tomato_final.tflite"
CLASSES_PATH = BASE_DIR / "models" / "krishisense_tomato_classes.txt"

IMAGE_SIZE = (224, 224)


def _load_labels():
    """Load class names from the model's class file."""
    with open(CLASSES_PATH, "r", encoding="utf-8") as file:
        return [line.strip() for line in file if line.strip()]


def _load_interpreter():
    """Load and initialize the TensorFlow Lite model."""
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model not found: {MODEL_PATH}")

    model_content = MODEL_PATH.read_bytes()

    interpreter = tf.lite.Interpreter(model_content=model_content)
    interpreter.allocate_tensors()

    return interpreter

def predict_image(image_path):
    """
    Run AI analysis on a tomato crop/leaf image.

    Parameters:
        image_path (str): Path to the input image.

    Returns:
        dict: Prediction, confidence, explanation and recommendation.
    """

    if not image_path:
        raise ValueError("Image path cannot be empty.")

    image_path = Path(image_path)

    if not image_path.exists():
        raise FileNotFoundError(f"Image not found: {image_path}")

    labels = _load_labels()
    interpreter = _load_interpreter()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    image = Image.open(image_path).convert("RGB")
    image = image.resize(IMAGE_SIZE, Image.Resampling.BILINEAR)

    # The verified TFLite model expects raw RGB values in the 0–255 range.
    image_array = np.array(image).astype(np.float32)
    input_data = np.expand_dims(image_array, axis=0)

    interpreter.set_tensor(
        input_details[0]["index"],
        input_data,
    )

    interpreter.invoke()

    output = interpreter.get_tensor(
        output_details[0]["index"]
    )[0]

    prediction_index = int(np.argmax(output))
    prediction = labels[prediction_index]
    confidence = float(output[prediction_index])

    explanation = (
        f"The model identified the image as {prediction.replace('_', ' ')} "
        f"with {confidence:.2%} confidence."
    )

    recommendation = (
        "This is an AI-assisted result, not a guaranteed diagnosis. "
        "Inspect the crop and consider expert guidance before treatment."
    )

    return {
        "prediction": prediction,
        "confidence": confidence,
        "explanation": explanation,
        "recommendation": recommendation,
    }


if __name__ == "__main__":
    result = predict_image("example.jpg")
    print(result)