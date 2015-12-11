// Generated by CoffeeScript 1.9.2
(function() {
  var Gpio, RpiInterface, people;

  Gpio = require('onoff').gpio;

  people = {
    "1A": {
      led: 12
    },
    "1B": {
      led: 24
    },
    "1C": {
      led: 23
    },
    "1D": {
      led: 18
    }
  };

  RpiInterface = (function() {
    function RpiInterface() {}

    RpiInterface.prototype.initialize = function() {
      return this.people = people.map(function(p) {
        return p.led = new Gpio(p.led, 'out');
      });
    };

    RpiInterface.prototype.initiateCall = function(sender) {
      var pin;
      pin = this.people[sender].led;
      console.log("Initiating call with sender " + sender);
      return pin.write(true);
    };

    return RpiInterface;

  })();

  module.exports = RpiInterface;

}).call(this);

//# sourceMappingURL=rpi_interface.js.map
