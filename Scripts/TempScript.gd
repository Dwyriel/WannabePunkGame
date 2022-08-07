extends Node2D

var Player0: Node;
var Player1: Node;

func _ready():
	LoadPlayer();

func LoadPlayer():
	Player0 = GlobalPreloads.PlayerScene.instance();
	Player1 = GlobalPreloads.PlayerScene.instance();
	var Player0Attributes = GlobalVariables.PlayerAttributes.new();
	var Player1Attributes = GlobalVariables.PlayerAttributes.new();
	Player0Attributes._custom_init(GlobalVariables.P0_DashInput, GlobalVariables.P0_RightInput, GlobalVariables.P0_LeftInput, GlobalVariables.P0_DownInput, GlobalVariables.P0_UpInput, $SpawnPoint1.position, GlobalPreloads.SpriteFrameGreen, Player1, false); #Either set the offset in the Spawnpoint itself or..
	Player1Attributes._custom_init(GlobalVariables.P1_DashInput, GlobalVariables.P1_RightInput, GlobalVariables.P1_LeftInput, GlobalVariables.P1_DownInput, GlobalVariables.P1_UpInput, $SpawnPoint2.position + Vector2(0, -8), GlobalPreloads.SpriteFrameRed, Player0, true); #..add (0,-8) to the position you actually want it to be
	if Player0.has_method("setExternalAttributes"):
		Player0.call("setExternalAttributes", Player0Attributes);
	if Player1.has_method("setExternalAttributes"):
		Player1.call("setExternalAttributes", Player1Attributes);
	Player0.name = "Player0";
	Player1.name = "Player1";
	self.add_child(Player0);
	self.add_child(Player1);
