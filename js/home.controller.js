angular.module('myApp').controller('ConnectController', function() {
  var $database, $host, $port, $query, $username, setSetting;
  setSetting = function($obj, val, def) {
    return $obj.val(val != null ? val : def);
  };
  $host = $('#host');
  $port = $('#port');
  $database = $('#db');
  $username = $('#username');
  $query = $('#query');
  setSetting($host, settings.host, 'localhost');
  setSetting($port, settings.port, '5432');
  setSetting($database, settings.database, global.process.env.USER);
  setSetting($username, settings.user, global.process.env.USER);
  return $('#connect').click(function() {
    var options;
    options = {};
    options.user = $username.val();
    options.password = $('#password').val();
    options.host = $host.val();
    options.port = $port.val();
    options.database = $database.val();
    return pg.connect(options, function(err, client, done) {
      var handleError, stringifiedSettings;
      handleError = function(err) {
        if (!err) {
          return false;
        }
        console.log(err.message);
        done(client);
        return true;
      };
      if (handleError(err)) {
        return;
      }
      settings.host = options.host;
      settings.port = options.port;
      settings.database = options.database;
      settings.user = options.user;
      stringifiedSettings = JSON.stringify(settings, null, 4);
      fs.writeFileSync(cwd + "/settings.json", stringifiedSettings);
      return client.query($query.val(), function(err, result) {
        var $row;
        if (handleError(err)) {
          return;
        }
        done();
        console.log(result.rows[0]);
        $row = $("<div>").addClass('row');
        $row.text(JSON.stringify(result.rows[0]));
        return $(document.body).append($row);
      });
    });
  });
});
