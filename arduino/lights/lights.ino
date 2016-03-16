int LOW_PIN = 2;
int HIGH_PIN = 13;

void setup() {
  Serial.println("YO DAWG");
  Serial.begin(9600);

  for (int i=LOW_PIN; i<= HIGH_PIN; i++) {
    pinMode(i, OUTPUT);
  }
  
  while (!Serial) ;
  Serial.println("ready");
}

void loop() {
  if (Serial.available() > 0) {
    int incomingByte = Serial.parseInt();
        
    if (incomingByte > 0) {
      digitalWrite(incomingByte, HIGH);
    } else {
      digitalWrite(abs(incomingByte), LOW);
    }
  }
}
