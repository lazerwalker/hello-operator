#include "HandsetSensor.h"
#include "Arduino.h"

#define CRADLED_VAL 512
#define HELD_VAL 511
#define DISCONNECTED_CUTOFF 1000

HandsetSensor::HandsetSensor(int pinNumber) {
  pin = pinNumber;
}

void HandsetSensor::setup() {
  pinMode(pin, INPUT_PULLUP);
  state = DISCONNECTED;
}

bool HandsetSensor::update() {
  HandsetState newState;
  int val = analogRead(pin);
  if(val >= DISCONNECTED_CUTOFF) {
    newState = DISCONNECTED;
  } else if (val >= CRADLED_VAL) {
    newState = CRADLED;
  } else {
    newState = HELD;
  }
  if (newState != state) {
    state = newState;
   return true;
  }

  return false;
}

