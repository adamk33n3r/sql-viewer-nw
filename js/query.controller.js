angular.module('myApp').controller('QueryController', function($scope, Query) {
  $scope.queryString = "";
  $scope.paginate = true;
  $scope.by = "10";
  $scope.page = "1";
  $scope.result = [];
  return $scope.query = function(queryString) {
    return Query(queryString, $scope, function(result) {
      return $scope.$apply(function() {
        return $scope.result = result.rows;
      });
    });
  };
});
