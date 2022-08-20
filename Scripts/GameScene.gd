extends Node2D

export var timeBeforeGoTime : int = 3; 

var Player0: KinematicBody2D;
var Player1: KinematicBody2D;
var Player0Pos : Vector2;
var Player1Pos : Vector2;
var timer : Timer;
var countdownLabel : Label;
var goTimeEnded : bool = false;

func _ready():
	set_physics_process(false);
	Player0Pos = $SpawnPoint1.position; #Offset accounted for in the spawnpoint itself
	Player1Pos = $SpawnPoint2.position + Vector2(0, -8); #Accounting for offset here
	timer = $Timer;
	countdownLabel = $CountdownLabel;
	countdownLabel.show();
	countdownLabel.text = String(timeBeforeGoTime);
	LoadPlayer();
	timer.start(1);

func LoadPlayer():
	Player0 = GlobalPreloads.PlayerScene.instance();
	Player1 = GlobalPreloads.PlayerScene.instance();
	Player0.call(GlobalVariables.methodSetExternalAttributes, CreatePlayerAttributes(Player1, GlobalVariables.Player0, true));
	Player1.call(GlobalVariables.methodSetExternalAttributes, CreatePlayerAttributes(Player0, GlobalVariables.Player1, false));
	self.add_child_below_node(timer, Player0);
	self.add_child_below_node(timer, Player1);

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

func _physics_process(delta):#Only being used for adding transparency to CountdownLabel for now, change it if needed to be use for other stuff
	countdownLabel.modulate.a -= 1.5 * delta;

func _on_Timer_timeout():
	if goTimeEnded:
		countdownLabel.hide();
		set_physics_process(false);
		return;
	timeBeforeGoTime -= 1;
	if timeBeforeGoTime > 0:
		countdownLabel.text = String(timeBeforeGoTime);
		timer.start(1);
	else:
		set_physics_process(true);
		countdownLabel.text = "Go";
		Player0.call(GlobalVariables.methodGameStart);
		Player1.call(GlobalVariables.methodGameStart);
		goTimeEnded = true;
		timer.start(.8);
