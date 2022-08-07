extends Node2D

var Player0Path: String = "res://Scenes/Player0.tscn";

var Player0PS: PackedScene = preload("res://Scenes/Player0.tscn");
var Player1PS: PackedScene = preload("res://Scenes/Player1.tscn");
var Player0: Node;
var Player1: Node;

func _ready():
	LoadPlayer();

func LoadPlayer():
	Player0 = Player0PS.instance();
	Player1 = Player1PS.instance();
	var Player0Attributes = GlobalVariables.PlayerAttributes.new();
	var Player1Attributes = GlobalVariables.PlayerAttributes.new();
	Player0Attributes._custom_init(
			GlobalVariables.P0_DashInput, 
			GlobalVariables.P0_RightInput, 
			GlobalVariables.P0_LeftInput, 
			GlobalVariables.P0_DownInput,
			GlobalVariables.P0_UpInput,
			Player1,
			$SpawnPoint1.position); #Either set the offset in the Spawnpoint itself or..
	Player1Attributes._custom_init(
			GlobalVariables.P1_DashInput, 
			GlobalVariables.P1_RightInput, 
			GlobalVariables.P1_LeftInput, 
			GlobalVariables.P1_DownInput,
			GlobalVariables.P1_UpInput,
			Player0,
			$SpawnPoint2.position + Vector2(0, -8)); #..add (0,-8) to the position you actually want it to be
	if Player0.has_method("setExternalAttributes"):
		Player0.call("setExternalAttributes", Player0Attributes);
	if Player1.has_method("setExternalAttributes"):
		Player1.call("setExternalAttributes", Player1Attributes);
	self.add_child(Player0);
	self.add_child(Player1);
