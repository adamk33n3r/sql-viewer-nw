var app, cwd, fs, nwGUI, os, pg, prettyBytes, settings;

os = requireNode('os');

prettyBytes = requireNode('pretty-bytes');

pg = requireNode('pg');

fs = requireNode('promised-io/fs');

nwGUI = requireNode('nw.gui');

cwd = global.process.cwd();

settings = requireNode(cwd + "/settings.json");

app = angular.module('myApp', ['ui.router', 'ui.bootstrap']).config(function($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) {
  $stateProvider.state('connect', {
    url: '/connect',
    templateUrl: cwd + "/html/connect.html",
    controller: 'ConnectController'
  });
  $stateProvider.state('query', {
    url: '/query',
    templateUrl: cwd + "/html/query.html",
    controller: 'QueryController'
  });
  $stateProvider.state('explore', {
    url: '/explore',
    templateUrl: cwd + "/html/explore.html",
    controller: 'ExploreController'
  });
  $stateProvider.state('explore.db', {
    url: '/:db',
    templateUrl: cwd + "/html/explore.db.html",
    controller: 'ExploreController'
  });
  $urlRouterProvider.otherwise('/home');
});

app.controller('AppController', function($rootScope, $state) {
  var cMenu, calcCPUUsage, getMemoryUsage;
  console.log("Initializing app...");
  cMenu = new nwGUI.Menu();
  cMenu.append(new nwGUI.MenuItem({
    label: 'Cut',
    click: function() {
      return document.execCommand('cut');
    }
  }));
  cMenu.append(new nwGUI.MenuItem({
    label: 'Copy',
    click: function() {
      return document.execCommand('copy');
    }
  }));
  cMenu.append(new nwGUI.MenuItem({
    label: 'Paste',
    click: function() {
      return document.execCommand('paste');
    }
  }));
  $(document).on('contextmenu', function(e) {
    e.preventDefault();
    if (e.target.tagName === 'TEXTAREA' || e.target.tagName === 'INPUT') {
      return cMenu.popup(e.originalEvent.x, e.originalEvent.y);
    }
  });
  $rootScope.$on('$stateChangeStart', function(e, toState) {
    console.log("Going to state: " + toState.name);
    if (toState.name !== 'connect' && ($rootScope.connectionConfig == null)) {
      $state.go('connect');
      return e.preventDefault();
    }
  });
  calcCPUUsage = function() {
    var _, cpu, i, j, len, ref, ref1, results, time, total, usage;
    ref = $rootScope.cpus;
    results = [];
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      cpu = ref[i];
      total = 0;
      ref1 = cpu.times;
      for (_ in ref1) {
        time = ref1[_];
        total += time;
      }
      usage = Math.round(100 * (total - cpu.times.idle) / total);
      results.push(usage);
    }
    return results;
  };
  getMemoryUsage = function() {
    return prettyBytes(os.freemem());
  };
  $rootScope.lastCPU = $rootScope.cpus = os.cpus();
  $rootScope.usages = calcCPUUsage();
  $rootScope.memoryUsage = getMemoryUsage();
  setInterval(function() {
    var cpu, cpus, i, j, len, ref, time, type;
    cpus = os.cpus();
    for (i = j = 0, len = cpus.length; j < len; i = ++j) {
      cpu = cpus[i];
      ref = cpu.times;
      for (type in ref) {
        time = ref[type];
        $rootScope.cpus[i].times[type] = Math.abs($rootScope.lastCPU[i].times[type] - time);
      }
    }
    return $rootScope.$apply(function() {
      $rootScope.usages = calcCPUUsage();
      $rootScope.memoryUsage = getMemoryUsage();
      return $rootScope.lastCPU = cpus;
    });
  }, 2000);
  this.close = function() {
    console.log(nwGUI);
    return nwGUI.App.closeAllWindows();
  };
  return this;
});

$(function() {
  var notice;
  notice = new Notification("SQL Query Viewer", {
    body: "Loaded"
  });
  notice.onshow = function(evt) {
    return setTimeout(function() {
      return notice.close();
    }, 5000);
  };
  return nwGUI.Window.get().showDevTools();
});
