class ServerStatus extends Gameplay.Mutator config(serverstatus);

var config string LoggingAddr;
var SSLink StatusLink;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	Log("ServerStatus initialized for addr "$LoggingAddr);

}

function PostBeginPlay()
{
	StatusLink = Spawn(class'SSLink');
}



defaultproperties
{
	LoggingAddr="tribesvengeance.com"
}