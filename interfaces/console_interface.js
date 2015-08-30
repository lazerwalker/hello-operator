// Generated by CoffeeScript 1.9.2
(function() {
  var ConsoleInterface, _,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require('underscore');

  ConsoleInterface = (function() {
    function ConsoleInterface(people, client) {
      this.people = people;
      this.client = client;
      this.connected = [];
      this.waitForInput();
    }

    ConsoleInterface.prototype.initiateCall = function(sender) {
      return console.log(sender + " is calling!");
    };

    ConsoleInterface.prototype.askToConnect = function(arg) {
      var receiver, sender;
      sender = arg.sender, receiver = arg.receiver;
      console.log("Picked up " + sender);
      return console.log("\"Hey, it's " + sender + ". Can I talk to " + receiver + "?\"");
    };

    ConsoleInterface.prototype.completeCall = function(arg) {
      var receiver, sender;
      sender = arg.sender, receiver = arg.receiver;
      return console.log(sender + " and " + receiver + " finished talking.");
    };

    ConsoleInterface.prototype.disconnectExisting = function(caller) {
      var existing, i, len, p;
      existing = _.filter(this.connected, function(pair) {
        return indexOf.call(pair, caller) >= 0;
      });
      for (i = 0, len = existing.length; i < len; i++) {
        p = existing[i];
        console.log("Auto-Disconnected " + p[0] + " and " + p[1]);
      }
      return this.connected = _.reject(this.connected, function(pair) {
        return indexOf.call(pair, caller) >= 0;
      });
    };

    ConsoleInterface.prototype.waitForInput = function() {
      process.stdin.resume();
      process.stdin.setEncoding('utf8');
      return process.stdin.on('data', (function(_this) {
        return function(text) {
          var c, first, i, len, match, other, ref, ref1, second;
          match = text.match(/(\w+) (\w+)/);
          ref = [match[1], match[2]], first = ref[0], second = ref[1];
          if (first === "me" || second === "me") {
            other = first === "me" ? second : first;
            if (indexOf.call(_this.connected, other) >= 0) {
              console.log("Disconnected " + other + " and operator");
              return _this.client.disconnectOperator(other);
            } else {
              _this.disconnectExisting(other);
              console.log("Connected " + other + " to operator");
              _this.connected.push([other, "me"]);
              return _this.client.connectOperator(other);
            }
          } else if (indexOf.call(_this.people, first) >= 0 && indexOf.call(_this.people, second) >= 0) {
            if (_.find(_this.connected, function(pair) {
              return indexOf.call(pair, first) >= 0 && indexOf.call(pair, second) >= 0;
            })) {
              console.log("Disconnected " + first + " and " + second + ".");
              return _this.client.disconnect(first, second);
            } else {
              ref1 = [first, second];
              for (i = 0, len = ref1.length; i < len; i++) {
                c = ref1[i];
                _this.disconnectExisting(c);
              }
              console.log("Connected " + first + " and " + second + ".");
              _this.connected.push([first, second]);
              return _this.client.connect(first, second);
            }
          }
        };
      })(this));
    };

    return ConsoleInterface;

  })();

  module.exports = ConsoleInterface;

}).call(this);
