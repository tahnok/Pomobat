(function() {
  var Pomobat,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Batman.config.minificationErrors = false;

  Pomobat = (function(_super) {

    __extends(Pomobat, _super);

    function Pomobat() {
      return Pomobat.__super__.constructor.apply(this, arguments);
    }

    Pomobat.root('pomodoros#all');

    return Pomobat;

  })(Batman.App);

  Pomobat.PomodorosController = (function(_super) {

    __extends(PomodorosController, _super);

    function PomodorosController() {
      this.doneBreak = __bind(this.doneBreak, this);

      this.donePomodoro = __bind(this.donePomodoro, this);

      this.updatePomodoro = __bind(this.updatePomodoro, this);
      PomodorosController.__super__.constructor.apply(this, arguments);
      this.set('currentPomodoro', new Pomobat.Pomodoro({
        state: "new"
      }));
    }

    PomodorosController.prototype.all = function() {
      return this.set('pomodoros', Pomobat.Pomodoro.get('all'));
    };

    PomodorosController.prototype.createPomodoro = function() {
      var _this = this;
      return this.get('currentPomodoro').save(function(err, pomodoro) {
        if (err) {
          if (!(err instanceof Batman.ErrorsSet)) {
            throw err;
          }
        } else {
          _this.set('currentPomodoro', new Pomobat.Pomodoro({
            state: "new"
          }));
          return _this.set('paused', false);
        }
      });
    };

    PomodorosController.prototype.startPomodoro = function() {
      var pomodoro;
      pomodoro = this.get('currentPomodoro');
      pomodoro.set('state', 'running');
      pomodoro.set('timeLeft', '25:00');
      pomodoro.save();
      return this.startTimer('25:00', this.donePomodoro, this.updatePomodoro);
    };

    PomodorosController.prototype.updatePomodoro = function(time) {
      return this.get('currentPomodoro').set('timeLeft', time);
    };

    PomodorosController.prototype.donePomodoro = function() {
      var pomodoro;
      pomodoro = this.get('currentPomodoro');
      pomodoro.set('state', 'finished');
      pomodoro.save();
      return alert("Pomodoro done!");
    };

    PomodorosController.prototype.togglePomodoro = function() {
      var state;
      state = this.get('paused');
      if (state) {
        this.resumePomodoro();
      } else {
        this.pausePomodoro();
      }
      console.log(state);
      return this.set('paused', !state);
    };

    PomodorosController.prototype.pausePomodoro = function() {
      var pomodoro;
      this.stopTimer();
      pomodoro = this.get('currentPomodoro');
      return pomodoro.set('state', 'paused');
    };

    PomodorosController.prototype.resumePomodoro = function() {
      var pomodoro;
      this.startTimer(this.get('timeLeft'), this.donePomodoro, this.updatePomodoro);
      pomodoro = this.get('currentPomodoro');
      return pomodoro.set('state', 'running');
    };

    PomodorosController.prototype.stopPomodoro = function() {
      var pomodoro;
      this.stopTimer();
      pomodoro = this.get('currentPomodoro');
      pomodoro.set('state', 'cancelled');
      return this.createPomodoro();
    };

    PomodorosController.prototype.startBreak = function() {
      return this.startTimer("5:00", this.doneBreak);
    };

    PomodorosController.prototype.doneBreak = function() {
      alert("break's over! get back to work!");
      return this.createPomodoro();
    };

    PomodorosController.prototype.startTimer = function(time, done, update) {
      var _this = this;
      this.set('timeLeft', time);
      window.tick = function() {
        return _this.tick(done, update);
      };
      return this.set('timeoutID', setTimeout(window.tick, 1000));
    };

    PomodorosController.prototype.pauseTimer = function() {};

    PomodorosController.prototype.stopTimer = function() {
      return window.clearTimeout(this.get('timeoutID'));
    };

    PomodorosController.prototype.tick = function(done, update) {
      var minutes, seconds, time;
      time = this.get('timeLeft').split(":");
      minutes = parseInt(time[0], 10);
      seconds = parseInt(time[1], 10);
      if ((minutes === 0) && (seconds === 0)) {
        return done();
      } else {
        if (seconds === 0) {
          minutes = minutes - 1;
          seconds = 59;
        } else {
          seconds = seconds - 1;
        }
        if (seconds < 10) {
          seconds = "0" + seconds;
        }
        time = "" + minutes + ":" + seconds;
        if (update) {
          update(time);
        }
        this.set('timeLeft', time);
        return this.set('timeoutID', setTimeout(window.tick, 1000));
      }
    };

    return PomodorosController;

  })(Batman.Controller);

  Pomobat.Pomodoro = (function(_super) {

    __extends(Pomodoro, _super);

    function Pomodoro() {
      return Pomodoro.__super__.constructor.apply(this, arguments);
    }

    Pomodoro.encode('title', 'state', 'timeLeft');

    Pomodoro.persist(Batman.LocalStorage);

    Pomodoro.storageKey = 'pomodoros-batman';

    Pomodoro.accessor('running', function() {
      if (this.get('state') === 'running') {
        return true;
      } else {
        return false;
      }
    });

    Pomodoro.accessor('finished', function() {
      if (this.get('state') === 'finished') {
        return true;
      } else {
        return false;
      }
    });

    Pomodoro.accessor('new', function() {
      if (this.get('state') === 'new') {
        return true;
      } else {
        return false;
      }
    });

    Pomodoro.classAccessor('finished', function() {
      return this.get('all').filter(function(pomodoro) {
        return pomodoro.get('state') === 'finished';
      });
    });

    return Pomodoro;

  })(Batman.Model);

  window.Pomobat = Pomobat;

  Pomobat.run();

  console.log("running");

}).call(this);
