int LOW_PIN = 2;
int HIGH_PIN = 13;

void setup() {
  Serial.begin(19200);

  for (int i=LOW_PIN; i<= HIGH_PIN; i++) {
    pinMode(i, OUTPUT);
  }
  
  Serial.println("ready");
}

void loop() {
  if (Serial.available() > 0) {
    int incomingByte = Serial.parseInt();
    Serial.println("In loop.");
    Serial.println("Value = " + String(incomingByte) + ", " + String(incomingByte+1));
    
    digitalWrite(2, HIGH);
    
    if (incomingByte > 0) {
      digitalWrite(incomingByte, HIGH);
    } else {
      digitalWrite(abs(incomingByte), LOW);
    }
  }
}
