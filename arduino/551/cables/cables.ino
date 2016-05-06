#define LOW_PIN 32
#define HIGH_PIN 51

#define LOW_CABLE 10
#define HIGH_CABLE 31

unsigned long DELAY = 100;

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
    unsigned long now = millis();
    int cableNum = i - LOW_CABLE;
    digitalWrite(i, LOW); 
      
    for (int j=LOW_PIN; j<=HIGH_PIN; j++) {
      int val = digitalRead(j);
      State *s = &state[cableNum][j];
      
      if (val == LOW) {
        if (state[cableNum][j] == NOT_CONNECTED) {
          *s = MAYBE_CONNECTED;
          timestamps[cableNum][j] = now;
          Serial.print(i);
          Serial.print(",");
          Serial.print(j);
          Serial.println(" are maybe connected");
        } else if (*s == MAYBE_CONNECTED) {
          Serial.print("Diff for ");
          Serial.print(i);
          Serial.print(",");
          Serial.print(j);
          Serial.print(" is ");
          Serial.print(now, 10);
          Serial.print(" - ");
          Serial.print(timestamps[cableNum][j], 10);
          Serial.print(" = ");
          
          Serial.println(now - timestamps[cableNum][j], 10);
          Serial.println(now == timestamps[cableNum][j]);
          if (now - timestamps[cableNum][j] >= DELAY) {
            Serial.println(onJSON(i, j));
            *s = CONNECTED;
            
          Serial.print(i);
          Serial.print(",");
          Serial.print(j);
          Serial.println(" are YES connected");
          }
        }
      } else if (val == HIGH) {
        if (*s == CONNECTED) {
          Serial.println(offJSON(i, j));
        } else if (*s == MAYBE_CONNECTED) {
          
          Serial.print(i);
          Serial.print(",");
          Serial.print(j);
          Serial.println(" are NO LONGER connected");
        }
        *s = NOT_CONNECTED;
      }
    }
    digitalWrite(i, HIGH);
    delay(10);
  }
}
