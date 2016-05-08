#define READY_PIN 11
#define DATA_PIN 12

#include "RotaryDial.h"

RotaryDial rotary(READY_PIN, DATA_PIN);

void setup() {
  Serial.begin(9600);
  Serial.println("Hello World");

  rotary.setup();
}


void loop() {
  if (rotary.update()) {
    Serial.println(rotary.getNumber());
  }
}
