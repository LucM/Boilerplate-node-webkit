angular.module('app', [])
.run ->
    gui = require('nw.gui')
    win = gui.Window.get()
    win.maximize()
    alert('ok')