{exec} = require 'child_process'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  exec 'coffee --compile --output assets/js/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

task 'auto_build', 'Continually compile', ->
  exec 'coffee -wc -o assets/js/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr