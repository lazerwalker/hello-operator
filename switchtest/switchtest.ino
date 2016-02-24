#include <SoftwareSerial.h>

SoftwareSerial mySerial(53, 52); 

const int LOW_PIN = 1;
int HIGH_PIN = 50;

int STATE_UNUSED = -1;

int state[55];

void setup() {
  mySerial.begin(9600); 
  mySerial.println("SETUP");
  Serial.begin(9600);
  Serial.println("Serial1");
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
      mySerial.println(String(i) + ": " + newState);
      state[i] = newState; 
    }
  }
}
