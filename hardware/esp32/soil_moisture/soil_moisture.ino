#define SOIL_PIN D0

const unsigned long READ_INTERVAL = 5UL * 60UL * 1000UL; // 5 minutes
unsigned long lastReadTime = 0;

void setup() {

  Serial.begin(115200);
  delay(2000);

  analogReadResolution(12);  // 0–4095

  Serial.println();
  Serial.println("==============================");
  Serial.println("XIAO ESP32-S3 Soil Moisture");
  Serial.println("==============================");
}

void loop() {

  unsigned long currentTime = millis();

  if (currentTime - lastReadTime >= READ_INTERVAL || lastReadTime == 0) {

    lastReadTime = currentTime;

    int rawValue = analogRead(SOIL_PIN);

    // Temporary conversion
    int moisturePercent = map(rawValue, 4095, 0, 0, 100);
    moisturePercent = constrain(moisturePercent, 0, 100);

    Serial.println();
    Serial.println("----- Soil Reading -----");

    Serial.print("Raw ADC: ");
    Serial.println(rawValue);

    Serial.print("Moisture: ");
    Serial.print(moisturePercent);
    Serial.println("%");

    Serial.println("------------------------");
  }
}
