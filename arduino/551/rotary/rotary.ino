int RINGING_PIN = 0;
int DATA_PIN_1 = 1;
int DATA_PIN_2 = 2;

bool isReading = false;
bool isLow = false;

int currentCount = 0;

void setup() {
  Serial.begin(9600);

  pinMode(RINGING_PIN, INPUT);
  pinMode(DATA_PIN_1, OUTPUT);
  pinMode(DATA_PIN_2, INPUT_PULLUP); 
}

void loop() {
  bool ringingPin = digitalRead(RINGING_PIN);
  if (!ringingPin) {
    isReading = true;
    currentCount = 0;
  } else if (ringingPin && isReading) {
    isReading = false;
    Serial.write(currentCount);
  }

  if (!isReading) { return; } // Delay?

  digitalWrite(DATA_PIN_1, HIGH);
  bool val = digitalRead(DATA_PIN_2);
  if (!val && !isLow) {
    isLow = true;
    currentCount++;
  } else if (val && isLow) {
    isLow = false;
  }
}
