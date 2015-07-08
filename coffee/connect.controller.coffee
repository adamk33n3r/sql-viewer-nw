angular.module 'myApp'
.controller 'ConnectController', ($rootScope, $state) ->
  setSetting = ($obj, val, def) ->
    $obj.val if val? then val else def

  $host = $('#host')
  $port = $('#port')
  $database = $('#db')
  $username = $('#username')

  setSetting $host, settings.host, 'localhost'
  setSetting $port, settings.port, '5432'
  setSetting $database, settings.database, global.process.env.USER
  setSetting $username, settings.user, global.process.env.USER

  $('#connect').click ->
    options = {}
    options.user = $username.val()
    options.password = $('#password').val()
    options.host = $host.val()
    options.port = $port.val()
    options.database = $database.val()
    pg.connect options, (err, client, done) ->
      handleError = (err) ->
        return false if !err
        console.log err.message
        done client
        return true
      return if handleError err

      console.log "Connected successfully"
      # Successful connection so save info (except password)
      settings.host = options.host
      settings.port = options.port
      settings.database = options.database
      settings.user = options.user
      stringifiedSettings = JSON.stringify settings, null, 4
      fs.writeFileSync "#{cwd}/settings.json", stringifiedSettings
      $rootScope.connectionConfig = options
      done()
      $state.go 'query'
  # $('#connect').click()
