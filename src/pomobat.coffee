
Batman.config.minificationErrors = false

class Pomobat extends Batman.App
  @root 'pomodoros#index'

class Pomobat.PomodorosController extends Batman.Controller
  constructor: ->
     super
     @set('pomodoros', Pomobat.Pomodoro.get('all'))
     @set('currentPomodoro', new Pomobat.Pomodoro())
     @set('sessionPomodoros', 0)
     @set('finishPomodoroSound', new buzz.sound('assets/sound/done2',
                                                {'preload': true, 'formats': ['mp3', 'ogg']}))
     @set('finishBreakSound', new buzz.sound('assets/sound/break_done',
                                                {'preload': true, 'formats': ['mp3', 'ogg']}))
     @setDefault('work_time', '25:00')
     @setDefault('break_time', '5:00')
     @setDefault('long_break_time', '20:00')
     @setDefault('use_sounds', 'true')

  setDefault:(key, value) ->
    if typeof localStorage[key] is 'undefined'
      localStorage[key] = value

  index: ->

  settings: ->


  newPomodoro: ->
    @get('currentPomodoro').save (err, pomodoro) =>
      if err
        throw err unless err instanceof Batman.ErrorsSet
      else
        @set('currentPomodoro', new Pomobat.Pomodoro())
        @set('paused', false)

  startPomodoro: ->
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'running')
    pomodoro.save()
    @startTimer(localStorage.work_time, @donePomodoro, @updatePomodoro)

  updatePomodoro: (time) =>
    @get('currentPomodoro').set('timeLeft', time)

  donePomodoro: =>
    window.document.title = "Pomodoro"
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'finished')
    pomodoro.save()
    @set('sessionPomodoros', @get('sessionPomodoros') + 1)
    @get('finishPomodoroSound').play() if localStorage.use_sounds == 'true'
    alert("Pomodoro done!")

  togglePaused: ->
    state = @get('paused')
    if state
      @resumePomodoro()
    else
      @pausePomodoro()
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
    window.document.title = "Pomodoro"
    pomodoro = @get('currentPomodoro')
    pomodoro.set('state', 'cancelled')
    @newPomodoro()

  startBreak: ->
    if @get('sessionPomodoros') % 4 == 0
      time = localStorage.long_break_time
    else
      time = localStorage.break_time
    @startTimer(time, @doneBreak)

  doneBreak: =>
    @get('finishBreakSound').play() if localStorage.use_sounds == 'true '
    alert("break's over! get back to work!")
    @newPomodoro()

  startTimer:(time, done, update) ->
    @set('timeLeft', time)
    window.tick = =>
      @tick(done, update)
    @set('timeoutID', setTimeout(window.tick, 1000))

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
      window.document.title = time + " | Pomobat"
      update(time) if update
      @set('timeLeft', time)
      @set('timeoutID', setTimeout(window.tick, 1000))

  popout: ->
    window.open('index.html', 'Pomobat', 'height=360,width=400,scrollbar=false')
    window.close()
    console.log("tried to close window")

  showSettings: ->
    $('#settings').slideToggle()
    @loadFormSettings()

  hideSettings: ->
    @saveFormSettings()
    $('#settings').slideToggle()

  loadFormSettings: ->
    $('#work_time').val(localStorage.work_time)
    $('#break_time').val(localStorage.break_time)
    $('#long_break_time').val(localStorage.long_break_time)
    $('#use_sounds').prop('checked', localStorage.use_sounds == 'true')

  saveFormSettings: ->
    for value in ['work_time', 'break_time', 'long_break_time']
      form_val = $('#' + value).val()
      localStorage[value] = form_val unless form_val == ''
    localStorage.use_sounds = $('#use_sounds').prop('checked') + ''

  toggleSound: ->
    localStorage.use_sounds = !(localStorage.use_sounds == 'true') + ''

class Pomobat.Pomodoro extends Batman.Model
  @encode 'title', 'state', 'timeLeft'
  @persist Batman.LocalStorage
  @storageKey: 'pomodoros-batman'

  constructor: ->
    @set('state', 'new')
    @set('timeLeft', localStorage.work_time)

  @accessor 'running', ->
    if @get('state') == 'running' then true else false

  @accessor 'finished', ->
    if @get('state') == 'finished' then true else false

  @accessor 'is_new', ->
    if @get('state') == 'new' then true else false

  @classAccessor 'finished', ->
    @get('all').filter (pomodoro) -> pomodoro.get('state') == 'finished'

# Make Pomobat available in the global namespace so it can be used
# as a namespace and bound to in views.
window.Pomobat = Pomobat
Pomobat.run()
console.log("running")