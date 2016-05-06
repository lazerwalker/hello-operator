#define LOW_PIN 32
#define HIGH_PIN 51

#define LOW_CABLE 10
#define HIGH_CABLE 31

unsigned long DELAY = 40;

enum State {
  NOT_CONNECTED,
  MAYBE_CONNECTED,
  CONNECTED
};

State state[20];
unsigned long timestamps[20];
int pair[20];

String onJSON(int a, int b) {
  return "{\"connected\": true, \"cable\": " + String(a) + ", \"port\": " + String(b) + "}";
}

String offJSON(int a, int b) {
  return "{\"connected\": false, \"cable\": " + String(a) + ", \"port\": " + String(b) + "}";
}

void setup() {
  Serial.begin(9600);
  Serial.println("\"cables\"");
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, INPUT_PULLUP);
  }

  for (int i=LOW_CABLE; i<= HIGH_CABLE; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }
}

void loop() {      
  for (int i=LOW_CABLE; i<=HIGH_CABLE; i++) {
    int cableNum = i - LOW_CABLE;
    unsigned long now = millis();
    digitalWrite(i, LOW); 
      
    for (int j=LOW_PIN; j<=HIGH_PIN; j++) {
      int val = digitalRead(j);

      if (val == LOW) {
        if (state[cableNum] == NOT_CONNECTED || pair[cableNum] != j) {
          state[cableNum] = MAYBE_CONNECTED;
          pair[cableNum] = j;
          timestamps[cableNum] = now;
        } else if (state[cableNum] == MAYBE_CONNECTED) {
          if (now - timestamps[cableNum] >= DELAY) {
            Serial.println(onJSON(i, j));
            state[cableNum] = CONNECTED;
          }
        }
      } else if (val == HIGH) {
        if (pair[cableNum] == j) {
          if (state[cableNum] == CONNECTED) {
            Serial.println(offJSON(i, j));
           } else if (state[cableNum] == MAYBE_CONNECTED) {
            pair[cableNum] = -1;
          }
          state[cableNum] = NOT_CONNECTED;
        }
      }
    }
    digitalWrite(i, HIGH);
    delay(10);
  }
}
