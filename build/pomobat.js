(function() {
  var Pomobat,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      PomodorosController.__super__.constructor.apply(this, arguments);
      this.set('newPomodoro', new Pomobat.Pomodoro({
        state: "new"
      }));
    }

    PomodorosController.prototype.all = function() {
      return this.set('pomodoros', Pomobat.Pomodoro.get('all'));
    };

    PomodorosController.prototype.createPomodoro = function() {
      var _this = this;
      return this.get('newPomodoro').save(function(err, pomodoro) {
        if (err) {
          if (!(err instanceof Batman.ErrorsSet)) {
            throw err;
          }
        } else {
          return _this.set('newPomodoro', new Pomobat.Pomodoro({
            state: "new"
          }));
        }
      });
    };

    PomodorosController.prototype.startPomodoro = function() {
      var pomodoro;
      pomodoro = this.get('newPomodoro');
      pomodoro.set('state', 'running');
      pomodoro.save();
      return console.log(pomodoro.get('title'));
    };

    return PomodorosController;

  })(Batman.Controller);

  Pomobat.Pomodoro = (function(_super) {

    __extends(Pomodoro, _super);

    function Pomodoro() {
      return Pomodoro.__super__.constructor.apply(this, arguments);
    }

    Pomodoro.encode('title', 'state');

    Pomodoro.persist(Batman.LocalStorage);

    Pomodoro.storageKey = 'pomodoros-batman';

    Pomodoro.accessor('running', function() {
      if (this.get('state') === 'running') {
        return true;
      } else {
        return false;
      }
    });

    Pomodoro.prototype.tester = function() {
      return true;
    };

    return Pomodoro;

  })(Batman.Model);

  window.Pomobat = Pomobat;

  Pomobat.run();

  console.log("running");

}).call(this);
