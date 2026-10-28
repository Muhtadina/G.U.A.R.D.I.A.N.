
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <TinyGPSPlus.h>

TinyGPSPlus gps;

// G.U.A.R.D.I.A.N. — Stage 1
// GPS-driven speed monitoring prototype.

constexpr int PIN_RED = 25;
constexpr int PIN_YELLOW = 26;
constexpr int PIN_GREEN = 27;
constexpr int PIN_BUZZER = 18;

constexpr int SCREEN_WIDTH = 128;
constexpr int SCREEN_HEIGHT = 64;

constexpr float CAUTION_SPEED = 60.0;
constexpr float HIGH_SPEED = 80.0;

// Treat GPS data as stale if no valid update arrives for 3 seconds.
constexpr unsigned long GPS_TIMEOUT_MS = 3000;

Adafruit_SSD1306 display(
  SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1
);

unsigned long lastGpsUpdate = 0;
unsigned long lastDisplayUpdate = 0;

bool gpsHasStarted = false;
bool gpsWasValid = false;

float speedKmph = 0.0;
enum SafetyState {
  GPS_LOST,
  NORMAL,
  CAUTION,
  HIGH_SPEED_ALERT
};

SafetyState previousState = GPS_LOST;
bool firstStateCheck = true;

void setup() {
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, 16, 17);

  pinMode(PIN_RED, OUTPUT);
  pinMode(PIN_YELLOW, OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);

  digitalWrite(PIN_RED, LOW);
  digitalWrite(PIN_YELLOW, LOW);
  digitalWrite(PIN_GREEN, LOW);
  digitalWrite(PIN_BUZZER, LOW);

  Wire.begin(21, 22);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("ERROR: OLED not detected.");
    while (true) {
      delay(1000);
    }
  }

  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);
  display.setCursor(0, 20);
  display.println("GUARDIAN starting...");
  display.display();

  Serial.println("GUARDIAN GPS monitoring initialized.");
  Serial.println("Thresholds are demonstration values only.");
}

void readGps() {
  while (Serial2.available() > 0) {
    char incoming = Serial2.read();

    if (gps.encode(incoming)) {
      // A complete, checksum-valid NMEA sentence arrived.
      if (gps.location.isValid() &&
          gps.speed.isValid() &&
          gps.location.age() < GPS_TIMEOUT_MS &&
          gps.speed.age() < GPS_TIMEOUT_MS) {
        lastGpsUpdate = millis();
        gpsHasStarted = true;
      }
    }
  }

  // Do not accept an old speed as current.
  if (gps.location.isValid() &&
      gps.speed.isValid() &&
      gps.location.age() < GPS_TIMEOUT_MS &&
      gps.speed.age() < GPS_TIMEOUT_MS) {
    lastGpsUpdate = millis();
    gpsHasStarted = true;
    speedKmph = gps.speed.kmph();
    gpsWasValid = true;
  } else {
    gpsWasValid = false;
  }
}

bool gpsDataFresh() {
  return gpsHasStarted &&
         gpsWasValid &&
         (millis() - lastGpsUpdate <= GPS_TIMEOUT_MS);
}

void updateAlerts() {
  // Fail-safe display state: no speed-based alerts without fresh GPS.
  if (!gpsDataFresh()) {
    digitalWrite(PIN_RED, LOW);
    digitalWrite(PIN_YELLOW, LOW);
    digitalWrite(PIN_GREEN, LOW);
    digitalWrite(PIN_BUZZER, LOW);
    return;
  }

  bool highSpeed = speedKmph >= HIGH_SPEED;
  bool caution = speedKmph >= CAUTION_SPEED && !highSpeed;
  bool normal = !caution && !highSpeed;

  digitalWrite(PIN_GREEN, normal ? HIGH : LOW);
  digitalWrite(PIN_YELLOW, caution ? HIGH : LOW);
  digitalWrite(PIN_RED, highSpeed ? HIGH : LOW);

  // Pulse the buzzer during the high-speed state.
  digitalWrite(
    PIN_BUZZER,
    highSpeed && ((millis() / 250) % 2 == 0) ? HIGH : LOW
  );
}

void updateDisplay() {
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);

  display.setCursor(0, 0);
  display.println("G.U.A.R.D.I.A.N.");

  display.setCursor(0, 10);

  if (!gpsDataFresh()) {
    display.println("GPS: SIGNAL LOST");

    display.setTextSize(2);
    display.setCursor(0, 26);
    display.println("-- km/h");

    display.setTextSize(1);
    display.setCursor(0, 48);
    display.println("Alerts disabled");
  } else {
    display.println("GPS: DATA VALID");

    display.setTextSize(2);
    display.setCursor(0, 22);
    display.print(speedKmph, 1);
    display.println(" km/h");

    display.setTextSize(1);
    display.setCursor(0, 42);

    if (gps.location.isValid()) {
      display.print("Lat:");
      display.println(gps.location.lat(), 2);
      display.print("Lon:");
      display.println(gps.location.lng(), 2);
    }

    display.setCursor(0, 58);

    if (speedKmph >= HIGH_SPEED) {
      display.print("ALERT: HIGH SPEED");
    } else if (speedKmph >= CAUTION_SPEED) {
      display.print("Status: CAUTION");
    } else {
      display.print("Status: NORMAL");
    }
  }

  display.display();
}

void logSafetyEvent() {
  SafetyState currentState;

  if (!gpsDataFresh()) {
    currentState = GPS_LOST;
  } else if (speedKmph >= HIGH_SPEED) {
    currentState = HIGH_SPEED_ALERT;
  } else if (speedKmph >= CAUTION_SPEED) {
    currentState = CAUTION;
  } else {
    currentState = NORMAL;
  }

  if (firstStateCheck || currentState != previousState) {
    Serial.print("[");
    Serial.print(millis() / 1000);
    Serial.print(" s] SAFETY EVENT: ");

    switch (currentState) {
      case GPS_LOST:
        Serial.println("GPS SIGNAL LOST");
        break;

      case NORMAL:
        Serial.println("NORMAL");
        break;

      case CAUTION:
        Serial.println("CAUTION - SPEED THRESHOLD EXCEEDED");
        break;

      case HIGH_SPEED_ALERT:
        Serial.println("HIGH SPEED - CRITICAL ALERT");
        break;
    }

    if (gpsDataFresh()) {
      Serial.print("Measured speed: ");
      Serial.print(speedKmph, 2);
      Serial.println(" km/h");
    }

    previousState = currentState;
    firstStateCheck = false;
  }
}

void loop() {
  readGps();

  unsigned long now = millis();

  if (now - lastDisplayUpdate >= 200) {
  lastDisplayUpdate = now;

  logSafetyEvent();
  updateAlerts();
  updateDisplay();
}

  // Periodic diagnostics
  static unsigned long lastDiagnostic = 0;

  if (now - lastDiagnostic >= 2000) {
    lastDiagnostic = now;

    Serial.println("\n--- GPS STATUS ---");

    if (gpsDataFresh()) {
      Serial.print("GPS speed: ");
      Serial.print(speedKmph, 2);
      Serial.println(" km/h");

      Serial.print("Latitude: ");
      Serial.println(gps.location.lat(), 6);

      Serial.print("Longitude: ");
      Serial.println(gps.location.lng(), 6);
    } else {
      Serial.println("GPS data unavailable or stale.");
    }

    Serial.print("Characters processed: ");
    Serial.println(gps.charsProcessed());

    Serial.print("Valid sentences: ");
    Serial.println(gps.passedChecksum());

    Serial.print("Failed checksums: ");
    Serial.println(gps.failedChecksum());
  }
}
