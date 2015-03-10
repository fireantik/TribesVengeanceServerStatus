class ServerStatus extends Gameplay.Mutator config(serverstatus);

var SSLink StatusLink;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	log("ServerStatus initialized");

}

function PostBeginPlay()
{
	StatusLink = Spawn(class'SSLink');
}