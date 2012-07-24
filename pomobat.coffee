Batman.config.minificationErrors = false

class Pomobat extends Batman.App
  @root 'pomodoros#all'

class Pomobat.PomodorosController extends Batman.Controller
  constructor: ->
     super
     @set 'newPomodoro', new Pomobat.Pomodoro(state: "new")

  all: ->
    @set 'pomodoros', Pomobat.Pomodoro.get('all')

  createPomodoro: ->
    @get('newPomodoro').save (err, pomodoro) =>
      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        @set 'newPomodoro', new Pomobat.Pomodoro(state: "new")

  startPomodoro: ->
    pomodoro = @get('newPomodoro')
    pomodoro.set('state', 'running')
    pomodoro.set('timeLeft', '0:10')
    pomodoro.save()
    @startTimer('0:10', @donePomodoro, @updatePomodoro)

  updatePomodoro: (time) =>
    @get('newPomodoro').set('timeLeft', time)

  donePomodoro: =>
    pomodoro = @get('newPomodoro')
    pomodoro.set('state', 'finished')
    alert("Pomodoro done!")

  startBreak: ->
    @startTimer("0:05", @doneBreak)

  doneBreak: =>
    alert("break's over! get back to work!")
    @set 'newPomodoro', new Pomobat.Pomodoro(state: "new")

  startTimer:(time, done, update) ->
    @set('timeLeft', time)
    window.tick = =>
      @tick(done, update)
    setTimeout(window.tick, 1000)

  tick:(done, update) ->
    time = @get('timeLeft').split(":")
    minutes = parseInt(time[0], 10)
    seconds = parseInt(time[1], 10)
    if (minutes == 0) and (seconds == 0)
      done()
    else
      if seconds == 0
        minutes = minutes - 1
        seconds = 59
      else
        seconds = seconds - 1
      seconds = "0" + seconds if seconds < 10
      time = "" + minutes + ":" + seconds
      update(time) if update
      @set('timeLeft', time)
      setTimeout(window.tick, 1000)


class Pomobat.Pomodoro extends Batman.Model
  @encode 'title', 'state', 'timeLeft'
  @persist Batman.LocalStorage
  @storageKey: 'pomodoros-batman'

  @accessor 'running', ->
    if @get('state') == 'running' then true else false

  @accessor 'finished', ->
    if @get('state') == 'finished' then true else false

  @accessor 'new', ->
    if @get('state') == 'new' then true else false



# Make Pomobat available in the global namespace so it can be used
# as a namespace and bound to in views.
window.Pomobat = Pomobat
Pomobat.run()
console.log("running")