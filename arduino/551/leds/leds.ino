

const int LOW_PIN = 3;
int HIGH_PIN = 52;


void setup() {
  Serial.begin(9600);
  
  Serial.println("\"lights\"");
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }

}

void loop() {
  while (Serial.available() > 0) {
    int pin = Serial.parseInt();
    int value = Serial.parseInt();
    Serial.println(String(pin) + ", " + String(value));
    if (pin >= LOW_PIN && pin <= HIGH_PIN && (value == 0 || value == 1)) {
      digitalWrite(pin, value);
    }
  }
}
