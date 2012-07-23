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
    pomodoro.save()
    console.log(pomodoro.get('title'))

class Pomobat.Pomodoro extends Batman.Model
  @encode 'title', 'state'
  @persist Batman.LocalStorage
  @storageKey: 'pomodoros-batman'

  @accessor 'running', ->
    if @get('state') == 'running' then true else false


# Make Pomobat available in the global namespace so it can be used
# as a namespace and bound to in views.
window.Pomobat = Pomobat
Pomobat.run()
console.log("running")