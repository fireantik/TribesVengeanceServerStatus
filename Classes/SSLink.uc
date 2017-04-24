class SSLink extends IpDrv.TcpLink config(serverstatus);

var PlayerController PC; //reference to our player controller
var config string TargetHost; //URL or P address of web server
var config int TargetPort; //port you want to use for the link
var string requesttext; //data we will send
var bool reporting;
var bool sending;

event BeginPlay()
{
    super.BeginPlay();
	
	reporting = false;
	sending = false;
    SetTimer(1, true);
    Log("[ServerStatus] BeginPlay. Host:" $ TargetHost);
}

function ResolveStats() //removes having to send a host
{
    Resolve(TargetHost);
}

event Resolved(IpAddr Addr)
{
    // The hostname was resolved succefully
    Log("[ServerStatus] " $ TargetHost $ " resolved to " $ IpAddrToString(Addr));

    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;

    //dont comment out this log because it rungs the function bindport
    Log("[ServerStatus] Bound to port: " $ BindPort());
    if (!Open(Addr))
    {
        log("[ServerStatus] Open failed");
    }
}

function Timer(){
  //Log("[ServerStatus] Timer");

  if(MultiplayerGameInfo(Level.Game).bOnGameEndCalled && !reporting){
    Log("[ServerStatus] Resolving");
    ResolveStats();
    reporting = true;
  }
}

event ResolveFailed()
{
    Warn("[ServerStatus] Unable to resolve " $ TargetHost);
}

event Opened()
{
  local string reportStr;
  local string encodedStr;
  local string finalStr;
  local int i;
  local array<string> lookup;
  local array<string> inA;
  local array<string> outA;
  
  if(sending){
	return;
  } else {
	sending = true;
  }
  
  Log("[ServerStatus] Connection opened, sending data");

  reportStr = GetReport();
  Base64EncodeLookupTable(lookup);
  inA[0] = reportStr;
  outA = Base64Encode(inA, lookup);
  encodedStr = outA[0];

  finalStr = "";
  
  SendText("POST /upload HTTP/1.1\r\n");
  SendText("Host: " $ TargetHost $ "\r\n");
  SendText("Connection: close\r\n");
  SendText("Content-length: " $ len(encodedStr) $ "\r\n");
  SendText("\r\n");
  
  SendText(encodedStr);
  SendText("\r\n");

  Log("[ServerStatus] Sent: " $ encodedStr);
  Log("[ServerStatus] End HTTP query");

  Close();
}

event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    log("[ServerStatus] Connection closed");
}

event ReceivedText(string Text)
{
    Log("[ServerStatus] ReceivedText: " $ Text);
}

function String GetReport()
{
  local string str;
  local MultiplayerGameInfo info;

  info = MultiplayerGameInfo(Level.Game);
  //info.


  str = "{";
  str $= KeyValue("serverreport", "true")@",";
  str $= KeyValue("ended", String(MultiplayerGameInfo(Level.Game).bOnGameEndCalled)) @ ",";
  str $= KeyValue("name", MultiplayerGameInfo(Level.Game).GameName) @ ",";
  str $= KeyValueInt("timelimit", MultiplayerGameInfo(Level.Game).TimeLimit) @ ",";
  str $= "\"players\":" $ ParsePlayers() @ ",";
  str $= KeyValue("port", string(Level.Game.GetServerPort()));
  str $= "}";

  return str;
}

function String KeyValue(string key, string value){
	return "\"" $ key $ "\":\"" $ value $ "\"";
}

function String KeyValueInt(string key, int value){
  return "\"" $ key $ "\":" $ value;
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
  for(CTRL = Level.ControllerList; CTRL != None; CTRL = CTRL.NextController)
  {
    c = PlayerCharacterController(CTRL);
    if(c == None) continue;
	
    pri = TribesReplicationInfo(c.PlayerReplicationInfo);
    if(pri == None) continue;
	
    IP = c.GetPlayerNetworkAddress();
    
    if(b) b = false;
    else r @= ",";

    r @= "{";

    r @= KeyValue("name", pri.PlayerName) @ ",";
    r @= KeyValue("ip", IP) @ ",";
    r @= KeyValueInt("ping", pri.Ping) @ ",";
    r @= KeyValueInt("starttime", pri.StartTime) @ ",";
    r @= KeyValue("voice", pri.VoiceSetPackageName) @ ",";
    r @= KeyValue("team", pri.team.localizedName) @ ",";

    r @= KeyValueInt("score", pri.Score) @ ",";
    r @= KeyValueInt("kills", pri.Kills) @ ",";
    r @= KeyValueInt("deaths", pri.Deaths) @ ",";
    r @= KeyValueInt("offense", pri.offenseScore) @ ",";
    r @= KeyValueInt("defense", pri.defenseScore) @ ",";
    r @= KeyValueInt("style", pri.styleScore);
    
    for(i=0; i < pri.statDataList.Length; i++)
    {
      ammount = pri.statDataList[i].amount;
      classname = String(pri.statDataList[i].statClass);

      r @= "," @ KeyValueInt(classname, ammount);
    }

    r @= "}";
  }

  return r@"]";
}

/**
  base64 encode an input array
*/
static function array<string> Base64Encode(array<string> indata, out array<string> B64Lookup)
{
  local array<string> result;
  local int i, dl, n;
  local string res;
  local array<byte> inp;
  local array<string> outp;
 
  if (B64Lookup.length != 64) Base64EncodeLookupTable(B64Lookup);
 
  // convert string to byte array
  for (n = 0; n < indata.length; n++)
  {
    res = indata[n];
    outp.length = 0;
    inp.length = 0;
    for (i = 0; i < len(res); i++)
    {
      inp[inp.length] = Asc(Mid(res, i, 1));
    }
 
    dl = inp.length;
	
    // fix byte array
    if ((dl%3) == 1)
    {
      inp[inp.length] = 0;
      inp[inp.length] = 0;
    }
	
    if ((dl%3) == 2)
    {
      inp[inp.length] = 0;
    }
    i = 0;
	
    while (i < dl)
    {
      outp[outp.length] = B64Lookup[(inp[i] >> 2)];
      outp[outp.length] = B64Lookup[((inp[i]&3)<<4) | (inp[i+1]>>4)];
      outp[outp.length] = B64Lookup[((inp[i+1]&15)<<2) | (inp[i+2]>>6)];
      outp[outp.length] = B64Lookup[(inp[i+2]&63)];
      i += 3;
    }
	
    // pad result
    if ((dl%3) == 1)
    {
      outp[outp.length-1] = "=";
      outp[outp.length-2] = "=";
    }
	
    if ((dl%3) == 2)
    {
      outp[outp.length-1] = "=";
    }
 
    res = "";
	
    for (i = 0; i < outp.length; i++)
    {
      res = res$outp[i];
    }
	
    result[result.length] = res;
  }
 
  return result;
}
 
/**
  Decode a base64 encoded string
*/
static function array<string> Base64Decode(array<string> indata)
{
  local array<string> result;
  local int i, dl, n, padded;
  local string res;
  local array<byte> inp;
  local array<string> outp;
 
  // convert string to byte array
  for (n = 0; n < indata.length; n++)
  {
    res = indata[n];
    outp.length = 0;
    inp.length = 0;
    padded = 0;
	
    for (i = 0; i < len(res); i++)
    {
      dl = Asc(Mid(res, i, 1));
      // convert base64 ascii to base64 index
      if ((dl >= 65) && (dl <= 90)) dl -= 65; // cap alpha
      else if ((dl >= 97) && (dl <= 122)) dl -= 71; // low alpha
      else if ((dl >= 48) && (dl <= 57)) dl += 4; // digits
      else if (dl == 43) dl = 62;
      else if (dl == 47) dl = 63;
      else if (dl == 61) padded++;
      inp[inp.length] = dl;
    }
 
    dl = inp.length;
    i = 0;
	
    while (i < dl)
    {
      outp[outp.length] = Chr((inp[i] << 2) | (inp[i+1] >> 4));
      outp[outp.length] = Chr(((inp[i+1]&15)<<4) | (inp[i+2]>>2));
      outp[outp.length] = Chr(((inp[i+2]&3)<<6) | (inp[i+3]));
      i += 4;
    }
	
    outp.length = outp.length-padded;
 
    res = "";
    for (i = 0; i < outp.length; i++)
    {
      res = res$outp[i];
    }
	
    result[result.length] = res;
  }
 
  return result;
}
 
/**
  Generate the base 64 encode lookup table
*/
static function Base64EncodeLookupTable(out array<string> LookupTable)
{
  local int i;
  for (i = 0; i < 26; i++)
  {
    LookupTable[i] = Chr(i+65);
  }
  
  for (i = 0; i < 26; i++)
  {
    LookupTable[i+26] = Chr(i+97);
  }
  
  for (i = 0; i < 10; i++)
  {
    LookupTable[i+52] = Chr(i+48);
  }
  
  LookupTable[62] = "+";
  LookupTable[63] = "/";
}

defaultproperties
{
    TargetHost = "stats.tribesrevengeance.com";
    TargetPort = 80;
}
