#define PIN A0

void setup() {
  Serial.begin(9600);
  Serial.println("hello world");

  pinMode(PIN, INPUT_PULLUP);
}

void loop() {
  // put your main code here, to run repeatedly:
  Serial.println(analogRead(PIN));
  delay(500);

  // 517 = no magnet
  // 518 = magnet, correct orientation
  // > 1000 = pin disconnected
}
