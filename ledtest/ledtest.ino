

const int LOW_PIN = 3;
int HIGH_PIN = 52;


void setup() {
  Serial.begin(9600);
  Serial.println("Hello!");
  for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    pinMode(i, OUTPUT);
    digitalWrite(i, HIGH);
  }

}

void loop() {
   for (int i=LOW_PIN; i<=HIGH_PIN; i++) {
    digitalWrite(i, HIGH);
  }
}
