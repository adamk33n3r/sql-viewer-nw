angular.module 'myApp'
.controller 'ConnectController', ->
  setSetting = ($obj, val, def) ->
    $obj.val if val? then val else def

  $host = $('#host')
  $port = $('#port')
  $database = $('#db')
  $username = $('#username')
  $query = $('#query')

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
      # Successful connection so save info (except password)
      settings.host = options.host
      settings.port = options.port
      settings.database = options.database
      settings.user = options.user
      stringifiedSettings = JSON.stringify settings, null, 4
      fs.writeFileSync "#{cwd}/settings.json", stringifiedSettings
      client.query $query.val(), (err, result) ->
        return if handleError err
        done()
        console.log result.rows[0]
        $row = $("<div>").addClass 'row'
        $row.text JSON.stringify result.rows[0]
        $(document.body).append $row
