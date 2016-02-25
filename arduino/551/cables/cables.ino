int LOW_PIN = 32;
int HIGH_PIN = 51;

int LOW_CABLE = 22;
int HIGH_CABLE = 31;

int STATE_UNUSED = -1;

int state[52];

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
    state[i] = STATE_UNUSED;
  }
}

void loop() {
  for (int i=LOW_CABLE; i<=HIGH_CABLE; i++) {
    digitalWrite(i, LOW);  
      
    for (int j=LOW_PIN; j<=HIGH_PIN; j++) {
      int val = digitalRead(j);
      
      if (val == LOW) {
        if (state[i] == STATE_UNUSED) {
          Serial.println(onJSON(i, j));
          state[i] = j;
          onJSON(i, j);
        }
        state[i] = j;
        
      } else if (val == HIGH) {
        if (state[i] == j) {
          Serial.println(offJSON(i, j));
          state[i] = STATE_UNUSED;
        }
      }
    }
    digitalWrite(i, HIGH);
    delay(10);
  }
}
