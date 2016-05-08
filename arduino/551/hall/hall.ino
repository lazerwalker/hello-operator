#define PIN A0
#include "HandsetSensor.h"

HandsetSensor sensor(PIN);

void setup() {
  Serial.begin(9600);
  Serial.println("hello world");
}

void loop() {
  // put your main code here, to run repeatedly:
  if (sensor.update()) {
    Serial.println(sensor.state);
  }
  delay(500);

  // 517 = no magnet
  // 518 = magnet, correct orientation
  // > 1000 = pin disconnected
}
