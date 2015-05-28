TribesVengeanceServerStatus
===========================

Tribes Vengeance mutator that reports player stats and info

Installation
============

Add ServerPackages=ServerStatus_v6b2 to your server.ini
Run server with mutator=ServerStatus_v6b2.ServerStatus parameter (like 'TV_CD_DVD.exe mp-emerald?mutator=ServerStatus_v6b2.ServerStatus')

Config file (serverstatus.ini)
==============================
```
[ServerStatus_v6b2.SSLink]
TargetHost="stats.tribesrevengeance.com"
TargetPort=80
Headers[0]="POST /upload HTTP/1.1"
Headers[1]="stats.tribesrevengeance.com"
Headers[2]="Connection: close"
```
