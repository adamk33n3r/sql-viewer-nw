os = requireNode('os')
prettyBytes = requireNode('pretty-bytes')
pg = requireNode 'pg'
fs = requireNode 'promised-io/fs'
nwGUI = requireNode 'nw.gui'

cwd = global.process.cwd()
settings = requireNode "#{cwd}/settings.json"
app = angular.module 'myApp', [
  'ui.router'
  'ui.bootstrap'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
  $stateProvider.state 'connect',
    url: '/connect'
    templateUrl: "#{cwd}/html/connect.html"
    controller: 'ConnectController'
  $stateProvider.state 'query',
    url: '/query'
    templateUrl: "#{cwd}/html/query.html"
    controller: 'QueryController'
  $stateProvider.state 'explore',
    url: '/explore'
    templateUrl: "#{cwd}/html/explore.html"
    controller: 'ExploreController'
  $stateProvider.state 'explore.db',
    url: '/:db'
    templateUrl: "#{cwd}/html/explore.db.html"
    controller: 'ExploreController'
  #- states:end
  # $urlRouterProvider.rule ($injector, $location) ->
  #   path = $location.path()
  #   if path[path.length - 1] is '/'
  #     newPath = path.substr 0, path.length - 1
  #     return newPath
  $urlRouterProvider.otherwise '/home'
  return

app.controller 'AppController', ($rootScope, $state) ->
  console.log "Initializing app..."

  cMenu = new nwGUI.Menu()
  cMenu.append new nwGUI.MenuItem
    label: 'Cut'
    click: ->
      document.execCommand 'cut'
  cMenu.append new nwGUI.MenuItem
    label: 'Copy'
    click: ->
      document.execCommand 'copy'
  cMenu.append new nwGUI.MenuItem
    label: 'Paste'
    click: ->
      document.execCommand 'paste'

  $(document).on 'contextmenu', (e) ->
    e.preventDefault()
    if e.target.tagName is 'TEXTAREA' or e.target.tagName is 'INPUT'
      cMenu.popup e.originalEvent.x, e.originalEvent.y

  $rootScope.$on '$stateChangeStart', (e, toState) ->
    console.log "Going to state: #{toState.name}"
    if toState.name isnt 'connect' and not $rootScope.connectionConfig?
      $state.go 'connect'
      e.preventDefault() # Cancel going to the route you were going to go
  calcCPUUsage = ->
    for cpu, i in $rootScope.cpus
      # console.log "CPU #{i}:"
      total = 0
      for _, time of cpu.times
        # continue if _ is 'idle'
        total += time
      usage = Math.round 100 * (total - cpu.times.idle) / total
      # console.log "\t", "Usage:", usage
      usage
  getMemoryUsage = ->
    prettyBytes os.freemem()
  $rootScope.lastCPU = $rootScope.cpus = os.cpus()
  $rootScope.usages = calcCPUUsage()
  $rootScope.memoryUsage = getMemoryUsage()
  setInterval ->
    cpus = os.cpus()
    for cpu, i in cpus
      for type, time of cpu.times
        $rootScope.cpus[i].times[type] = Math.abs $rootScope.lastCPU[i].times[type] - time
    $rootScope.$apply ->
      $rootScope.usages = calcCPUUsage()
      $rootScope.memoryUsage = getMemoryUsage()
      $rootScope.lastCPU = cpus
  , 2000
  @close = ->
    console.log nwGUI
    nwGUI.App.closeAllWindows()
  return this


$ ->
  notice = new Notification "SQL Query Viewer",
    body: "Loaded"
  notice.onshow = (evt) ->
    setTimeout ->
      notice.close()
    , 5000
  nwGUI.Window.get().showDevTools()

