angular.module 'myApp'
.controller 'QueryController', ($scope, Query) ->
  $scope.queryString = ""
  $scope.paginate = true
  $scope.by = "10"
  $scope.page = "1"
  $scope.result = []
  $scope.query = (queryString) ->
    Query queryString, $scope, (result) ->
      $scope.$apply ->
        $scope.result = result.rows
