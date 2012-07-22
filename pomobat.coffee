Batman.config.minificationErrors = false

class Pomobat extends Batman.App
  @root 'pomodoros#all'

class Pomobat.PomodorosController extends Batman.Controller
  all: ->
    @set 'pomodoros', Pomobat.Pomodoro.get('all')

class Pomobat.Pomodoro extends Batman.Model
  @encode 'title', 'completed'
  @persist Batman.LocalStorage

  @classAccessor 'completed', ->
      @get('all').filter (todo) -> todo.get('completed')

# Make Pomobat available in the global namespace so it can be used
# as a namespace and bound to in views.
window.Pomobat = Pomobat
Pomobat.run()