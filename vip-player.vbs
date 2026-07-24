Set objShell = CreateObject("WScript.Shell")
scriptDir = objShell.CurrentDirectory
htmlPath = scriptDir & "\vip-player.html"
Set objShellApp = CreateObject("Shell.Application")
objShellApp.Open htmlPath
