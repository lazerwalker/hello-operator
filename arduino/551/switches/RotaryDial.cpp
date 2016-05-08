#include "RotaryDial.h"
#include "Arduino.h"

RotaryDial::RotaryDial(int readyPin, int dataPin){
  
}

void RotaryDial::setup() {
  pinMode(readyPin, INPUT_PULLUP);
  pinMode(dataPin, INPUT_PULLUP);
  
  changeState(WAITING);
  currentCount = 0;
}

bool RotaryDial::update() {
  bool readyVal = digitalRead(readyPin);
  bool dataVal = digitalRead(dataPin);
  
  if (currentState == WAITING) {
    if (readyVal == HIGH && changeStateIfDebounced(LISTENING_NOPULSE)) {
      currentCount = 0;
    }
  } else if (currentState == LISTENING_NOPULSE) {
    if (readyVal == LOW && changeStateIfDebounced(WAITING)) {
      if (currentCount == 0) {
        currentCount = NO_NUM;
      } else if (currentCount == 10) {
        currentCount = 0;
      }
      return true;
    } else if (dataVal == HIGH && changeStateIfDebounced(LISTENING_PULSE)) {
      currentCount++;
    } 
  } else if (currentState == LISTENING_PULSE) {
    if (dataVal == LOW) {
      changeStateIfDebounced(LISTENING_NOPULSE);
    }
  }
  return false;
}

int RotaryDial::getNumber() {
  return currentCount;
}

bool RotaryDial::checkDebounce() {
   return (millis() - lastStateChange) > PULSE_RATE;
}

bool RotaryDial::changeStateIfDebounced(RotaryState newState) {
  if (checkDebounce()) {
    changeState(newState);
    return true;
  }
  return false;
}

void RotaryDial::changeState(RotaryState newState) {
  currentState = newState;
  lastStateChange = millis();
}

