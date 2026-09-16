/*
 * ==============================================================================
 * Project: Real-Time Heart Rate (BPM) Calculation via Moving Threshold QRS
 * Course: Introduction to Biomedical Engineering (IBME), Fall 2023
 * Author: Alireza Najafi Motiei (Student ID: 810100224)
 * Instructor: Dr. Majid Badiee Rostami
 * Department: Faculty of Electrical and Computer Engineering, University of Tehran
 * ------------------------------------------------------------------------------
 * Algorithm: Circular buffer sampling, normalization, and R-peak thresholding.
 * ==============================================================================
 */

const float R_THRESHOLD = 0.6;     // Normalized threshold for R-peak detection
const int BUFFER_SIZE = 200;       // Analysis window size

int dataBuffer[BUFFER_SIZE];
int bufferIndex = 0;
unsigned long lastPeakTime = 0;
float currentBPM = 0.0;

void setup() {
  Serial.begin(9600);
  pinMode(4, INPUT); // LO+
  pinMode(7, INPUT); // LO-
}

void loop() {
  if ((digitalRead(4) == 1) || (digitalRead(7) == 1)) {
    Serial.println("Leads Disconnected");
  } else {
    int sensorValue = analogRead(A0);
    dataBuffer[bufferIndex] = sensorValue;
    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE;

    // Normalize peak detection
    float normalizedVal = (float)sensorValue / 1023.0;
    if (normalizedVal > R_THRESHOLD) {
      unsigned long currentTime = millis();
      unsigned long rrInterval = currentTime - lastPeakTime;
      
      // Enforce physiological refractory period (> 300 ms, corresponding to < 200 BPM)
      if (rrInterval > 300 && lastPeakTime != 0) {
        currentBPM = 60000.0 / (float)rrInterval;
        Serial.print("R-Peak Detected | RR: ");
        Serial.print(rrInterval);
        Serial.print(" ms | Instantaneous BPM: ");
        Serial.println(currentBPM);
      }
      lastPeakTime = currentTime;
    }
  }
  delay(10);
}
