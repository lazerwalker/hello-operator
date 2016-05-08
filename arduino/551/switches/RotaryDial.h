#define PULSE_RATE 10
#define NO_NUM -1

enum RotaryState {
  WAITING,
  LISTENING_NOPULSE,
  LISTENING_PULSE
};

class RotaryDial{
  public:
    RotaryDial(int readyPin, int dataPin);
    void setup();
    bool update();
    int getNumber();
    
  private:
    int readyPin;
    int dataPin;
    
    RotaryState currentState;
    int currentCount;
    unsigned long lastStateChange; // in MS

    bool checkDebounce();
    bool changeStateIfDebounced(RotaryState newState);
    void changeState(RotaryState newState);
};

