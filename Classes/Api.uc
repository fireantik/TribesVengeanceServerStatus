/*=============================================================================
	WebServer is responsible for listening to requests on the selected http
	port and will guide requests to the correct application.
=============================================================================*/

class Api extends UWeb.WebServer;

function BeginPlay()
{
    Log("TribesVengeanceServerStatus.Api.BeginPlay");

	Super.BeginPlay();
}

event GainedChild( Actor C )
{
    // Log("TribesVengeanceServerStatus.Api.GainedChild: "$C.Name);

	//Super.GainedChild(C);
	ConnectionCount++;

	// if too many connections, close down listen.
	if(MaxConnections > 0 && ConnectionCount > MaxConnections && LinkState == STATE_Listening)
	{
		Log("TribesVengeanceServerStatus.Api: Too many connections - closing down Listen.");
		Close();
	}
}

event LostChild( Actor C )
{
    // Log("TribesVengeanceServerStatus.Api.LostChild: "$C.Name);

	// Super.LostChild(C);
	ConnectionCount--;

	// if closed due to too many connections, start listening again.
	if(ConnectionCount <= MaxConnections && LinkState != STATE_Listening)
	{
		Log("TribesVengeanceServerStatus.Api: Listening again - connections have been closed.");
		Listen();
	}
}

function WebApplication GetApplication(string URI, out string SubURI)
{
	local int i, l;

    // Log("WebServer.GetApplication: "$URI $", "$SubURI);

	SubURI = "";
	for(i=0;i<10;i++)
	{
		if(ApplicationPaths[i] != "")
		{
			l = Len(ApplicationPaths[i]);
			if(Left(URI, l) == ApplicationPaths[i] && (Len(URI) == l || Mid(URI, l, 1) == "/"))
			{
				SubURI = Mid(URI, l);
				return ApplicationObjects[i];
			}
		}
	}
	return None;
}

defaultproperties
{
	ExpirationSeconds=86400
	ListenPort=80
	LinkMode=MODE_Text
	AcceptClass=class'UWeb.WebResponse'
	Applications[0]="TribesVengeanceServerStatus.HelloWeb"
	ApplicationPaths[0]="/ServerAdmin"
	MaxConnections=30
    bEnabled=True
	DefaultApplication=-1
}