TribesVengeanceServerStatus
===========================

Tribes Vengeance mutator that reports player stats and info

Installation
============

Add ServerPackages=ServerStatus_v6 to your server.ini
Run server with mutator=ServerStatus_v6.ServerStatus parameter

Config file (serverstatus.ini)
==============================
```
[ServerStatus_v6.SSLink]
TargetHost="stats.tribesrevengeance.com"
TargetPort=80
Headers[0]="POST /upload HTTP/1.1"
Headers[1]="stats.tribesrevengeance.com"
Headers[2]="Connection: close"
```
