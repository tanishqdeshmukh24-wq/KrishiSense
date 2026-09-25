import numpy as np
from PIL import Image
import tensorflow as tf

MODEL_PATH = "models/krishisense_tomato_final.tflite"
IMAGE_PATH = r"C:\Users\asus\Downloads\bc5416cb-a48f-4ed0-ab8e-0ffd7ef25f12___RS_HL 9992.JPG"

interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

image = Image.open(IMAGE_PATH).convert("RGB")
image = image.resize((224, 224), Image.Resampling.BILINEAR)

image = np.array(image).astype(np.float32)

# SAME preprocessing currently used by Flutter
#image = (image / 127.5) - 1.0

input_data = np.expand_dims(image, axis=0)

interpreter.set_tensor(
    input_details[0]["index"],
    input_data
)

interpreter.invoke()

output = interpreter.get_tensor(
    output_details[0]["index"]
)[0]

labels = [
    "bacterial_spot",
    "early_blight",
    "healthy",
    "late_blight",
    "leaf_mold",
    "septoria_leaf_spot",
    "spider_mites_two_spotted_spider_mite",
    "target_spot",
    "tomato_mosaic_virus",
    "tomato_yellow_leaf_curl_virus"
]

print("\nMODEL OUTPUT\n")

for label, probability in zip(labels, output):
    print(f"{label:45s} {probability:.8f}")

prediction = int(np.argmax(output))

print("\nPrediction:", labels[prediction])
print("Confidence:", float(output[prediction]))

print("\nInput statistics:")
print("min:", image.min())
print("max:", image.max())
print("mean:", image.mean())