TribesVengeanceServerStatus
===========================

Tribes Vengeance mutator that reports player stats and info

Installation
============

Add ServerPackages=ServerStatus_v5 to your server.ini
Run server with mutator=ServerStatus_v5.ServerStatus parameter

Config file (serverstatus.ini)
==============================
[ServerStatus_v5.SSLink]
TargetHost="obscure-bastion-3104.herokuapp.com"
TargetPort=80
Headers[0]="POST /upload HTTP/1.1"
Headers[1]="Host: obscure-bastion-3104.herokuapp.com"
Headers[2]="Connection: close"