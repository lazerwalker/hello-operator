#define RINGING_PIN 11
#define DATA_PIN 12

#define PULSE_RATE 10
#define NO_NUM -1

enum State {
  WAITING,
  LISTENING_NOPULSE,
  LISTENING_PULSE
};

void changeState(State newState);
bool changeStateIfDebounced(State newState);

int currentCount;
State currentState;

unsigned long lastStateChange; // in MS

void setup() {
  Serial.begin(9600);

  pinMode(RINGING_PIN, INPUT_PULLUP);
  pinMode(DATA_PIN, INPUT_PULLUP);
 
  Serial.println("Hello World");

  changeState(WAITING);
  currentCount = 0;
}

bool checkDebounce() {
   return (millis() - lastStateChange) > PULSE_RATE;
}

bool changeStateIfDebounced(State newState) {
  if (checkDebounce()) {
    changeState(newState);
    return true;
  }
  return false;
}

void changeState(State newState) {
  currentState = newState;
  lastStateChange = millis();
}

void loop() {
  bool ringingPin = digitalRead(RINGING_PIN);
  bool dataPin = digitalRead(DATA_PIN);
  
  if (currentState == WAITING) {
    if (ringingPin == HIGH && changeStateIfDebounced(LISTENING_NOPULSE)) {
      currentCount = 0;
    }
  } else if (currentState == LISTENING_NOPULSE) {
    if (ringingPin == LOW && changeStateIfDebounced(WAITING)) {
      if (currentCount == 0) {
        currentCount = NO_NUM;
      } else if (currentCount == 10) {
        currentCount = 0;
      }
      Serial.println(currentCount);
    } else if (dataPin == HIGH && changeStateIfDebounced(LISTENING_PULSE)) {
      currentCount++;
    } 
  } else if (currentState == LISTENING_PULSE) {
    if (dataPin == LOW) {
      changeStateIfDebounced(LISTENING_NOPULSE);
    }
  }
}
