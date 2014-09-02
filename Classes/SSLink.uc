class SSLink extends IpDrv.TcpLink config(serverstatus);

var PlayerController PC; //reference to our player controller
var config string TargetHost; //URL or P address of web server
var config int TargetPort; //port you want to use for the link
var config string path; //path to file you want to request
var config string requesttext; //data we will send
var int score; //score the player controller will send us
var bool send; //to switch between sending and getting requests
var bool reported;

event PostBeginPlay()
{
    super.PostBeginPlay(); 
    SetTimer(1,true);
}

function ResolveMe() //removes having to send a host
{
    Resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
    // The hostname was resolved succefully
    Log("[SSLink] "$TargetHost$" resolved to "$ IpAddrToString(Addr));

    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;

    //dont comment out this log because it rungs the function bindport
    Log("[SSLink] Bound to port: "$ BindPort() );
    if (!Open(Addr))
    {
        //`Log("[TcpLinkClient] Open failed");
    }
}

function Timer(){
  if(MultiplayerGameInfo(Level.Game).bOnGameEndCalled && !reported){
    ResolveMe();
    reported = true;
  }
}

event ResolveFailed()
{
    //`Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.

    //send failed message to scaleform UI
    //JunHud(JunPlayerController(PC).myHUD).JunMovie.CallSetHTML("Failed");
}

event Opened()
{
	requesttext = "stuff="$ GetReport();

	SendText("POST /"$path$" HTTP/1.0"$chr(13)$chr(10));
	SendText("Host: "$TargetHost$chr(13)$chr(10));
	SendText("User-Agent: HTTPTool/1.0"$Chr(13)$Chr(10));
	SendText("Content-Type: application/x-www-form-urlencoded"$chr(13)$chr(10));
	//we use the length of our requesttext to tell the server
	//how long our content is
	SendText("Content-Length: "$len(requesttext)$Chr(13)$Chr(10));
	SendText(chr(13)$chr(10));
	SendText(requesttext);
	SendText(chr(13)$chr(10));
	SendText("Connection: Close");
	SendText(chr(13)$chr(10)$chr(13)$chr(10));

	Log("[SSLink] end HTTP query");
}

event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    Log("[SSLink] event closed");

    // After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event ReceivedText( string Text )
{
    local array<String> resp;
    Split(Text, chr(13)$chr(10)$chr(13)$chr(10), resp);

    Log("[SSLink] SplitText:: " $resp[1]);
}

function String GetReport()
{
  local string str;
  local MultiplayerGameInfo info;

  info = MultiplayerGameInfo(Level.Game);
  //info.


  str = "{";
  str $= KeyValue("serverreport","true")@",";
  str $= KeyValue("ended",String(MultiplayerGameInfo(Level.Game).bOnGameEndCalled))@",";
  str $= KeyValue("name",MultiplayerGameInfo(Level.Game).GameName)@",";
  str $= KeyValueInt("timelimit",MultiplayerGameInfo(Level.Game).TimeLimit)@",";
  str $= "\"players\":"$ParsePlayers()@",";
  str $= KeyValue("port", string(Level.Game.GetServerPort()) );
  str $= "}";

  return str;
}

function String KeyValue(string key, string value){
	return "\""$key$"\":\""$value$"\"";
}

function String KeyValueInt(string key, int value){
  return "\""$key$"\":"$value;
}

function String ParsePlayers(){
  local String r,classname;
  local Controller CTRL;
  local PlayerCharacterController c;
  local bool b;
  local TribesReplicationInfo pri;
  local int i,ammount;
  local StatData std;
  local string IP;

  r = "[";

  b = true;
  for( CTRL=Level.ControllerList;CTRL!=None;CTRL=CTRL.NextController )
  {
    if(b)b = false;
    else r @= ",";

    c = PlayerCharacterController(CTRL);
    pri = TribesReplicationInfo(c.PlayerReplicationInfo);
    IP = c.GetPlayerNetworkAddress();


    r @= "{";

    r @= KeyValue("name", pri.PlayerName)@",";
    r @= KeyValue("ip", IP);
    r @= KeyValueInt("ping", pri.Ping)@",";
    r @= KeyValueInt("starttime", pri.StartTime)@",";
    r @= KeyValue("voice", pri.VoiceSetPackageName)@",";
    r @= KeyValue("team", pri.team.localizedName)@",";

    r @= KeyValueInt("score", pri.Score)@",";
    r @= KeyValueInt("kills", pri.Kills)@",";
    r @= KeyValueInt("deaths", pri.Deaths)@",";
    r @= KeyValueInt("offense", pri.offenseScore)@",";
    r @= KeyValueInt("defense", pri.defenseScore)@",";
    r @= KeyValueInt("style", pri.styleScore);
    
    for( i=0; i<pri.statDataList.Length; i++ )
    {
      ammount = pri.statDataList[i].amount;
      classname = String(pri.statDataList[i].statClass);

      r @= ","@KeyValueInt(classname, ammount);
    }

    r @= "}";
  }

  return r@"]";
}

defaultproperties
{
    TargetHost="stats.tribesrevengeance.com"
    TargetPort=80 //default for HTTP
    path = "reportserverstatus.php"
    send = false;
    reported = false;
}