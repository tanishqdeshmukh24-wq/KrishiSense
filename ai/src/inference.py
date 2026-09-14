"""
KrishiSense AI Inference Module

This module will provide crop-health image predictions.
The actual trained model will be connected in a later phase.
"""


def predict_image(image_path):
    """
    Run AI analysis on a crop/leaf image.

    Parameters:
        image_path (str): Path to the input image.

    Returns:
        dict: Prediction result.
    """

    if not image_path:
        raise ValueError("Image path cannot be empty.")

    return {
        "prediction": "MODEL_NOT_LOADED",
        "confidence": 0.0,
        "explanation": "AI model has not been trained and loaded yet.",
        "recommendation": "No recommendation available until model inference is implemented."
    }


if __name__ == "__main__":
    result = predict_image("example.jpg")
    print(result)