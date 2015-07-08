gulp = require 'gulp'
coffee = require 'gulp-coffee'
coffeeify = require 'gulp-coffeeify'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
plumber = require 'gulp-plumber'
child = require 'child_process'
del = require 'del'

childProcesses = {}

startNW = ->
  if 'nw' of childProcesses
    childProcesses.nw.kill()
  nwProcess = childProcesses.nw = child.spawn './node_modules/nw/bin/nw', ['--debug', '--enable-transparent-visuals', '--disable-gpu', '.']

  nwProcess.on 'exit', ->
    process.exit()
  # nwProcess.stderr.on 'data', (data) ->
  #  log = data.toString().match(/\[.*\]\s+(.*), source:.*\/(.*)/)
  #  if log
  #    process.stdout.write "[node] #{log.slice(1).join(' ')}\n"

reload = null
gulp.task 'setupReload', ->
  require 'net'
    .createServer (socket) ->
      reload = socket
    .listen 9292

gulp.task 'nw', ['build', 'setupReload'], startNW

gulp.task 'build:scripts', buildCoffee

gulp.task 'coffeeify', ->
  gulp.src 'coffee/**/*.coffee'
    .pipe coffeeify
      debug: true
      paths: [__dirname + '/coffee']
    .pipe gulp.dest './build/js'
  return

buildCoffee = ->
  gulp.src 'coffee/**/*.coffee'
    .pipe plumber()
    .pipe coffee
      bare: true
    .on 'error', (err) -> console.log "[#{err.name}](#{err.filename.replace(/.*\//, '')}:#{err.location.first_line}:#{err.location.first_column}) #{err.message}"
    .pipe gulp.dest 'js'
  return
gulp.task 'build:coffee', buildCoffee

buildCSS = ->
  gulp.src 'stylus/**/*.styl'
    .pipe plumber()
    .pipe stylus
      linenos: true
    .on 'error', (err) -> console.log err
    .pipe gulp.dest 'css'
gulp.task 'build:css', buildCSS

buildJade = ->
  gulp.src 'jade/**/*.jade'
    .pipe jade
      pretty: true
    .on 'error', -> return
    .pipe gulp.dest 'html'
gulp.task 'build:jade', buildJade

gulp.task 'watch', ->
  console.log "Now watching for file changes"
  gulp.watch 'coffee/**/*.coffee', ['reload']
  gulp.watch 'stylus/**/*.styl', ['reload']
  gulp.watch 'jade/**/*.jade', ['reload']


gulp.task 'build', ['clean', 'build:jade', 'build:css', 'build:coffee']

gulp.task 'reload', ['build'], ->
  setTimeout ->
    console.log "Reloading..."
    reload.write 'reload' if reload?
  , 500

gulp.task 'clean', (cb) ->
  del [
    'js/*'
    'html/*'
  ], cb

gulp.task 'default', ['nw', 'watch']
