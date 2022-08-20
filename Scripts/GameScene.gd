extends Node2D

export var timeBeforeGoTime : int = 3; 

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
	var player1Character = GlobalVariables.Characters.Red if GlobalVariables.CharacterPicked == GlobalVariables.Characters.Green else GlobalVariables.Characters.Green; 
	GlobalVariables.Player0 = GlobalPreloads.PlayerScene.instance();
	GlobalVariables.Player1 = GlobalPreloads.PlayerScene.instance();
	GlobalVariables.Player0.call(GlobalVariables.methodreceiveInitParams, GlobalVariables.CharacterPicked, GlobalVariables.PlayerInput.Player0);
	GlobalVariables.Player1.call(GlobalVariables.methodreceiveInitParams, player1Character, GlobalVariables.PlayerInput.Player1);
	GlobalVariables.Player0.position = Player0Pos;
	GlobalVariables.Player1.position = Player1Pos;
	self.add_child_below_node(get_child(1), GlobalVariables.Player0);
	self.add_child_below_node(get_child(1), GlobalVariables.Player1);

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
		GlobalVariables.Player0.call(GlobalVariables.methodGameStart);
		GlobalVariables.Player1.call(GlobalVariables.methodGameStart);
		goTimeEnded = true;
		timer.start(.8);
