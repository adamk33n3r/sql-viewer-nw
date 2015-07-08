angular.module 'myApp'
.controller 'ExploreController', ($rootScope, $scope, $state, $stateParams, Query) ->
  console.log $state.current.name
  if $state.current.name is 'explore.db'
    console.log $stateParams
  else
    Query 'select datname from pg_database where datistemplate = false;', $scope, (result) ->
      $scope.$apply ->
        $scope.databases = (db.datname for db in result.rows)
    Query "select schema_name from information_schema.schemata", $scope, (result) ->
      $scope.$apply ->
        $scope.schemas = result.rows
    Query "select table_schema, table_name from information_schema.tables where table_schema = 'gis' order by table_schema, table_name;", $scope, (result) ->
      $scope.$apply ->
        $scope.tables = (table for table in result.rows)
        console.log $scope.tables
  $('#pieces > .piece').draggable
    containment: '#board'
    stack: '#pieces div'
    cursor: 'move'
    revert: true
    helper: 'clone'
  $('.dropzone').droppable
    accept: '.piece'
    hoverClass: 'hovered'
    drop: (e, ui) ->
      newPiece = ui.draggable.clone()
      newPiece.draggable
        containment: '#board'
        stack: '#pieces div'
        cursor: 'move'
        revert: true
        helper: 'clone'
      console.log e, ui
      ui.draggable.addClass 'correct'
      ui.draggable.draggable 'disable'
      $(this).droppable 'disable'
      $(this).append(ui.draggable)
      # $(this).children '.inner'
        # .hide()
      # ui.draggable.position
      #   of: $(this)
      #   my: 'left top'
      #   at: 'left+4 top+4'
      ui.draggable.draggable 'option', 'revert', false

      $('#pieces').append newPiece
