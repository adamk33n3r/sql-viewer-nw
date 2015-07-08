angular.module 'myApp'
.factory 'Query', ($rootScope) ->
  (queryString, $scope, cb) -> # Passing in scope? Bad. Oh well
    applyMods = (qstr) ->
      qstr += " limit #{$scope.by} offset #{($scope.page - 1) * $scope.by}" if $scope.paginate
      console.log qstr
      return qstr
    pg.connect $rootScope.connectionConfig, (err, client, done) ->
      handleError = (err) ->
        return false if !err
        console.log err.message
        done client
        return true
      return if handleError err

      client.query applyMods(queryString), (err, result) ->
        return if handleError err
        done()
        cb(result)
