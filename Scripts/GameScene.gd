extends Node2D

var Player0: KinematicBody2D;
var Player1: KinematicBody2D;

var Player0Pos : Vector2;
var Player1Pos : Vector2; 

func _ready():
	Player0Pos = $SpawnPoint1.position;
	Player1Pos = $SpawnPoint2.position + Vector2(0, -8);
	LoadPlayer();

func LoadPlayer():
	Player0 = GlobalPreloads.PlayerScene.instance();
	Player1 = GlobalPreloads.PlayerScene.instance();
	Player0.call(GlobalVariables.methodSetExternalAttributes, CreatePlayerAttributes(Player1, GlobalVariables.Player0, true));
	Player1.call(GlobalVariables.methodSetExternalAttributes, CreatePlayerAttributes(Player0, GlobalVariables.Player1, false));
	self.add_child(Player0);
	self.add_child(Player1);

func CreatePlayerAttributes(otherPlayer : KinematicBody2D, character, isMainCharacter : bool):
	var playerAttributes = GlobalVariables.PlayerAttributes.new();
	playerAttributes._custom_init(
			GlobalVariables.P0_DashInput if isMainCharacter else GlobalVariables.P1_DashInput, 
			GlobalVariables.P0_RightInput if isMainCharacter else GlobalVariables.P1_RightInput, 
			GlobalVariables.P0_LeftInput if isMainCharacter else GlobalVariables.P1_LeftInput, 
			GlobalVariables.P0_DownInput if isMainCharacter else GlobalVariables.P1_DownInput, 
			GlobalVariables.P0_UpInput if isMainCharacter else GlobalVariables.P1_UpInput, 
			Player0Pos if isMainCharacter else Player1Pos, 
			GlobalPreloads.SpriteFrameGreen if character == GlobalVariables.Characters.Green else GlobalPreloads.SpriteFrameRed, 
			otherPlayer, 
			!isMainCharacter);
	return playerAttributes;
