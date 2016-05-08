#include "HandsetSensor.h"
#include "RotaryDial.h"

HandsetSensor handset = HandsetSensor(A0);
RotaryDial rotary = RotaryDial(11, 12);

const int LOW_PIN = 5;
int HIGH_PIN = 51;

int STATE_UNUSED = -1;

int state[55];

String switchJSON(int pin, int val) {
  String truth = "false";
  if (val) {
    truth = "true";
  }
  return "{\"pin\": " + String(pin) + ", \"value\": " + truth + "}";
}

String json(String type, int val) {
  return  "{\"type\": \"" + String(type) + "\", \"value\": " + String(val) + "}";
}

void setup() {
  Serial.begin(9600);
  Serial.println("\"switches\"");

  handset.setup();
  rotary.setup();
  
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, INPUT_PULLUP);
    state[i] = STATE_UNUSED;
  }

}

void loop() {
  int i=LOW_PIN;
  for (i=LOW_PIN; i<=HIGH_PIN; i++) {
    int oldState = state[i];
    int newState = digitalRead(i);

    if (oldState != newState) {
      Serial.println(switchJSON(i, newState));
      state[i] = newState; 
    }
  }

  if (handset.update()) {
    Serial.println(json("handset", handset.state));
  }

  if (rotary.update()) {
    Serial.println(json("rotary", rotary.getNumber()));
  }
}
