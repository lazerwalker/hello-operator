// Generated by CoffeeScript 1.9.2
(function() {
  var Game, exports, root,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  if (root._ == null) {
    root._ = require('underscore');
  }

  Game = (function() {
    Game.prototype.people = ["1A", "1B", "1C", "1D", "1E", "2A", "2B", "2C", "2D", "2E"];

    function Game() {
      this.addNewCall = bind(this.addNewCall, this);
      this.disconnect = bind(this.disconnect, this);
      this.connect = bind(this.connect, this);
      this.disconnectOperator = bind(this.disconnectOperator, this);
      this.connectOperator = bind(this.connectOperator, this);
      this.calls = [];
      this.interfaces = [];
    }

    Game.prototype.connectOperator = function(caller) {
      var call, i, j, len, ref, results;
      call = root._(this.calls).findWhere({
        sender: caller
      });
      if (!call) {
        return;
      }
      if (call.pickedUp) {
        return;
      }
      call.pickedUp = true;
      ref = this.interfaces;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        results.push(i.askToConnect(call));
      }
      return results;
    };

    Game.prototype.disconnectOperator = function(caller) {};

    Game.prototype.connect = function(first, second) {
      var call, i, j, len, ref;
      call = root._(this.calls).findWhere({
        sender: first,
        receiver: second
      });
      if (!call) {
        call = root._(this.calls).findWhere({
          sender: second,
          receiver: first
        });
      }
      if (!(call && call.pickedUp)) {
        return;
      }
      ref = this.interfaces;
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        i.completeCall(call);
      }
      first.busy = false;
      second.busy = false;
      this.calls = root._(this.calls).without(call);
      return this.addNewCall();
    };

    Game.prototype.disconnect = function(first, second) {};

    Game.prototype.addNewCall = function() {
      var first, i, instruction, j, len, ref, ref1, results, second;
      ref = root._(this.people).chain().reject(function(p) {
        return p.busy;
      }).sample(2).value(), first = ref[0], second = ref[1];
      if (!(first && second)) {
        return;
      }
      instruction = {
        sender: first,
        receiver: second
      };
      first.busy = true;
      second.busy = true;
      this.calls.push(instruction);
      ref1 = this.interfaces;
      results = [];
      for (j = 0, len = ref1.length; j < len; j++) {
        i = ref1[j];
        results.push(i.initiateCall(instruction.sender));
      }
      return results;
    };

    Game.prototype.addInterface = function(i) {
      i.people = this.people;
      i.client = this;
      return this.interfaces.push(i);
    };

    Game.prototype.startGame = function() {
      return this.addNewCall();
    };

    return Game;

  })();

  if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
    module.exports = Game;
  } else if (typeof exports !== "undefined" && exports !== null) {
    exports = Game;
  } else {
    this.Game = Game;
  }

}).call(this);
