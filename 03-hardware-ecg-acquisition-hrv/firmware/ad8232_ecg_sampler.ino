/*
 * ==============================================================================
 * Project: Real-Time ECG Biopotential Acquisition & Lead-Off Monitoring
 * Course: Introduction to Biomedical Engineering (IBME), Fall 2023
 * Author: Alireza Najafi Motiei (Student ID: 810100224)
 * Instructor: Dr. Majid Badiee Rostami
 * Department: Faculty of Electrical and Computer Engineering, University of Tehran
 * ------------------------------------------------------------------------------
 * Target Hardware: Arduino Uno / Nano / Micro + Analog Devices AD8232 AFE
 * Pin Configuration:
 *   - AD8232 OUTPUT  -> Arduino Analog Pin A0
 *   - AD8232 LO+     -> Arduino Digital Pin 4 (Leads-off Detection +)
 *   - AD8232 LO-     -> Arduino Digital Pin 7 (Leads-off Detection -)
 *   - AD8232 3.3V    -> Arduino 3.3V (Regulated Rail)
 *   - AD8232 GND     -> Arduino GND (Common Ground)
 * ==============================================================================
 */

const int PIN_OUTPUT = A0;  // Analog input from AD8232 front-end
const int PIN_LO_PLUS = 4;  // Lead-off detection pin +
const int PIN_LO_MINUS = 7; // Lead-off detection pin -

void setup() {
  // Initialize serial communication at 9600 bps for MATLAB/PC telemetry
  Serial.begin(9600);
  
  // Configure digital inputs for active electrode detachment monitoring
  pinMode(PIN_LO_PLUS, INPUT);
  pinMode(PIN_LO_MINUS, INPUT);
}

void loop() {
  // Check if electrodes are disconnected (leads-off condition)
  if ((digitalRead(PIN_LO_PLUS) == 1) || (digitalRead(PIN_LO_MINUS) == 1)) {
    // Lead disconnected: transmit indicator
    Serial.println('!');
  } else {
    // Read 10-bit biopotential voltage level (0 - 1023) mapped from 0 - 3.3V
    int rawECG = analogRead(PIN_OUTPUT);
    Serial.println(rawECG);
  }
  
  // Sampling rate control: ~95-100 Hz delay
  delay(10);
}
