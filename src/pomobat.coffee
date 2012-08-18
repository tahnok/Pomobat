Batman.config.minificationErrors = false

class Pomobat extends Batman.App
  @root 'pomodoros#all'

class Pomobat.PomodorosController extends Batman.Controller
  constructor: ->
     super
     @set('currentPomodoro', new Pomobat.Pomodoro(state: "new"))

  all: ->
    @set('pomodoros', Pomobat.Pomodoro.get('all'))

  createPomodoro: ->
    @get('currentPomodoro').save (err, pomodoro) =>
      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        @set('currentPomodoro', new Pomobat.Pomodoro(state: "new"))
        @set('paused', false)

  startPomodoro: ->
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'running')
    pomodoro.set('timeLeft', '25:00')
    pomodoro.save()
    @startTimer('25:00', @donePomodoro, @updatePomodoro)

  updatePomodoro: (time) =>
    @get('currentPomodoro').set('timeLeft', time)

  donePomodoro: =>
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'finished')
    pomodoro.save()
    $('#sound').html("<embed src='assets/sound/done2.wav' hidden='true' autostart='true' loop='false'>")
    alert("Pomodoro done!")

  togglePomodoro: ->
    state = @get('paused')
    if state
      @resumePomodoro()
    else
      @pausePomodoro()
    console.log(state)
    @set('paused', !state)

  pausePomodoro: ->
    @stopTimer()
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'paused')

  resumePomodoro: ->
    @startTimer(@get('timeLeft'), @donePomodoro, @updatePomodoro)
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'running')

  stopPomodoro: ->
    @stopTimer()
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'cancelled')
    @createPomodoro()

  startBreak: ->
    @startTimer("5:00", @doneBreak)

  doneBreak: =>
    alert("break's over! get back to work!")
    @createPomodoro()

  startTimer:(time, done, update) ->
    @set('timeLeft', time)
    window.tick = =>
      @tick(done, update)
    @set('timeoutID', setTimeout(window.tick, 1000))

  pauseTimer: ->

  stopTimer: ->
    window.clearTimeout(@get('timeoutID'))

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
      @set('timeoutID', setTimeout(window.tick, 1000))


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

  @classAccessor 'finished', ->
    @get('all').filter (pomodoro) -> pomodoro.get('state') == 'finished'

# Make Pomobat available in the global namespace so it can be used
# as a namespace and bound to in views.
window.Pomobat = Pomobat
Pomobat.run()
console.log("running")
