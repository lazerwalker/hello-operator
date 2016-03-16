

const int LOW_PIN = 5;
int HIGH_PIN = 51;

int STATE_UNUSED = -1;

int state[55];

void setup() {
  Serial.begin(9600);
  Serial.println("Hello!");
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
      Serial.println(String(i) + "," + String(newState));
      state[i] = newState; 
    }
  }
}
