#define SOIL_PIN D0

// ==============================
// Node Information
// ==============================
const char* NODE_NAME = "Farm Sensor 1";
const char* NODE_ID   = "FS001";
const char* ZONE_ID   = "ZONE001";

// ==============================
// Reading Settings
// ==============================
const unsigned long READ_INTERVAL = 5UL * 60UL * 1000UL; // 5 minutes

// Temporary calibration values
const int DRY_VALUE = 4095;
const int WET_VALUE = 1176;

unsigned long lastReadTime = 0;

void setup() {

  Serial.begin(115200);
  delay(2000);

  analogReadResolution(12);  // 0–4095

  Serial.println();
  Serial.println("================================");
  Serial.println("     KRISHISENSE SENSOR NODE");
  Serial.println("================================");

  Serial.print("Node Name: ");
  Serial.println(NODE_NAME);

  Serial.print("Node ID: ");
  Serial.println(NODE_ID);

  Serial.print("Zone ID: ");
  Serial.println(ZONE_ID);

  Serial.println("Reading Interval: 5 minutes");
  Serial.println("================================");
}

void loop() {

  unsigned long currentTime = millis();

  // First reading immediately, then every 5 minutes
  if (currentTime - lastReadTime >= READ_INTERVAL || lastReadTime == 0) {

    lastReadTime = currentTime;

    // Take 10 quick readings for averaging
    long total = 0;

    for (int i = 0; i < 10; i++) {
      total += analogRead(SOIL_PIN);
      delay(100);
    }

    int averageRaw = total / 10;

    // Convert ADC value to temporary moisture percentage
    int moisturePercent = map(
      averageRaw,
      DRY_VALUE,
      WET_VALUE,
      0,
      100
    );

    moisturePercent = constrain(moisturePercent, 0, 100);

    // ==============================
    // Display Reading
    // ==============================

    Serial.println();
    Serial.println("----- Soil Reading -----");

    Serial.print("Node: ");
    Serial.println(NODE_NAME);

    Serial.print("Node ID: ");
    Serial.println(NODE_ID);

    Serial.print("Zone: ");
    Serial.println(ZONE_ID);

    Serial.print("Average ADC: ");
    Serial.println(averageRaw);

    Serial.print("Moisture: ");
    Serial.print(moisturePercent);
    Serial.println("%");

    Serial.println("------------------------");
  }
}
