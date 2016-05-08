enum HandsetState {
  CRADLED,
  HELD,
  DISCONNECTED 
};

class HandsetSensor {
  public:
    /**
    * Create a new HandsetSensor listening on the given pin.
    * @param pin An analog input connected to a Hall Effect sensor
    */
    HandsetSensor(int pin);

    /** The current state of the handset */
    HandsetState state;

    /** Sets up the given output */
    void setup();

    /** Polls the Hall Effect sensor to update the current state of the handset.
    * @return bool Whether the state has changed since the last update. 
    */
    bool update();

  private:
    unsigned int pin;
};

