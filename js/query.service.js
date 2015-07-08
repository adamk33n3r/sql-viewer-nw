angular.module('myApp').factory('Query', function($rootScope) {
  return function(queryString, $scope, cb) {
    var applyMods;
    applyMods = function(qstr) {
      if ($scope.paginate) {
        qstr += " limit " + $scope.by + " offset " + (($scope.page - 1) * $scope.by);
      }
      console.log(qstr);
      return qstr;
    };
    return pg.connect($rootScope.connectionConfig, function(err, client, done) {
      var handleError;
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
      return client.query(applyMods(queryString), function(err, result) {
        if (handleError(err)) {
          return;
        }
        done();
        return cb(result);
      });
    });
  };
});
