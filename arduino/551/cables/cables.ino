#define LOW_PIN 32
#define HIGH_PIN 51

#define LOW_CABLE 10
#define HIGH_CABLE 31

#define DELAY 200

enum State {
  NOT_CONNECTED,
  MAYBE_CONNECTED,
  CONNECTED
};

State state[20][50];
unsigned long timestamps[20][50];

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
    digitalWrite(i, LOW);  
      
    for (int j=LOW_PIN; j<=HIGH_PIN; j++) {
      int val = digitalRead(j);
      unsigned long *timestamp = &timestamps[cableNum][j];
      State *s = &state[cableNum][j];
      
      unsigned long now = millis();
      
      if (val == LOW) {
        if (*s == NOT_CONNECTED) {
          *s = MAYBE_CONNECTED;
          *timestamp = now;
        }
        else if (*s == MAYBE_CONNECTED) {
          if (now - *timestamp > DELAY) {
            Serial.println(onJSON(i, j));
            *s = CONNECTED;
          }
        }
      } else if (val == HIGH) {
        if (*s == CONNECTED) {
          Serial.println(offJSON(i, j));
        }
        *s = NOT_CONNECTED;
      }
    }
    digitalWrite(i, HIGH);
    delay(10);
  }
}
