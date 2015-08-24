int LOW_PIN = 2;
int HIGH_PIN = 12;

int STATE_UNUSED = -1;

int state[20];

String onJSON(int a, int b) {
  return "{\"type\": \"on\", \"values\": [" + String(a) + "," + String(b) + "]}";
}

String offJSON(int a, int b) {
  return "{\"type\": \"off\", \"values\": [" + String(a) + "," + String(b) + "]}";
}

void setup() {
  Serial.begin(9600);
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, INPUT_PULLUP);
    
    state[i] = STATE_UNUSED;
  }
}

void loop() {
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW);  
      
    for (int j=LOW_PIN; j<=HIGH_PIN; j++) {
      if (i == j) { continue; }
      
      int val = digitalRead(j);
      
      if (val == LOW) {
        if (state[j] == STATE_UNUSED) {
          Serial.println(onJSON(i, j));
        }
        state[j] = i;
        state[i] = j;
        
      } else if (val == HIGH) {
        if (state[j] == i && state[i] == j) {
          Serial.println(offJSON(i, j));
          state[i] = STATE_UNUSED;
          state[j] = STATE_UNUSED;
        }
      }
    }
    
    pinMode(i, INPUT_PULLUP);
  }
}
