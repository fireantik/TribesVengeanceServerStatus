TribesVengeanceServerStatus
===========================

Tribes Vengeance mutator that reports player stats and info

[Download](https://github.com/jkelin/TribesVengeanceServerStatus/releases)

Installation
============

1. Drop TribesVengeanceServerStatus.u file into your server's Bin directory
2. Add `ServerActors=TribesVengeanceServerStatus.SSLink` to your server.ini under `[Engine.GameEngine]` category

If you have installed the mod correcly, you should see '[ServerStatus] init. Host:' in your server console after game starts (you need to comment `Suppress=ScriptLog` in your sever.ini to see this).

Config file (serverstatus.ini)
==============================
```
[TribesVengeanceServerStatus.SSLink]
TargetHost="report.stats.tribesrevengeance.net"
TargetPort=80
```
