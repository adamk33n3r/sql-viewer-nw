angular.module('myApp').controller('ExploreController', function($rootScope, $scope, $state, $stateParams, Query) {
  console.log($state.current.name);
  if ($state.current.name === 'explore.db') {
    console.log($stateParams);
  } else {
    Query('select datname from pg_database where datistemplate = false;', $scope, function(result) {
      return $scope.$apply(function() {
        var db;
        return $scope.databases = (function() {
          var i, len, ref, results;
          ref = result.rows;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            db = ref[i];
            results.push(db.datname);
          }
          return results;
        })();
      });
    });
    Query("select schema_name from information_schema.schemata", $scope, function(result) {
      return $scope.$apply(function() {
        return $scope.schemas = result.rows;
      });
    });
    Query("select table_schema, table_name from information_schema.tables where table_schema = 'gis' order by table_schema, table_name;", $scope, function(result) {
      return $scope.$apply(function() {
        var table;
        $scope.tables = (function() {
          var i, len, ref, results;
          ref = result.rows;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            table = ref[i];
            results.push(table);
          }
          return results;
        })();
        return console.log($scope.tables);
      });
    });
  }
  $('#pieces > .piece').draggable({
    containment: '#board',
    stack: '#pieces div',
    cursor: 'move',
    revert: true,
    helper: 'clone'
  });
  return $('.dropzone').droppable({
    accept: '.piece',
    hoverClass: 'hovered',
    drop: function(e, ui) {
      var newPiece;
      newPiece = ui.draggable.clone();
      newPiece.draggable({
        containment: '#board',
        stack: '#pieces div',
        cursor: 'move',
        revert: true,
        helper: 'clone'
      });
      console.log(e, ui);
      ui.draggable.addClass('correct');
      ui.draggable.draggable('disable');
      $(this).droppable('disable');
      $(this).append(ui.draggable);
      ui.draggable.draggable('option', 'revert', false);
      return $('#pieces').append(newPiece);
    }
  });
});
