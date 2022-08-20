extends Node2D

export var timeBeforeGoTime : int = 3; 
export var labelFadeSpeed : float = 1.5;
export var timeBeforeHideCountdownLabel : float = .8;
export var drawWaitTime : float = 2;

enum Results { Player0Won, Player1Won, Draw };
var result : int = -1;
var Player0Pos : Vector2;
var Player1Pos : Vector2;
var timer : Timer;
var countdownLabel : Label;
var gameOverCountdownLabel : Label;
var gameOverLabel : Label;
var gameOverNode : Node;
var player0HasDied : bool = false;
var player1HasDied : bool = false;

func _ready():
	GlobalVariables.currentGameScene = GlobalVariables.GameScenes.Game;
	set_physics_process(false);
	set_process(false);
	Player0Pos = $SpawnPoint1.position; #Offset accounted for in the spawnpoint itself
	Player1Pos = $SpawnPoint2.position + Vector2(0, -8); #Accounting for offset here
	timer = $Timer;
	gameOverCountdownLabel = $LabelNode/GameOverCountdownLabel;
	gameOverCountdownLabel.hide();
	gameOverLabel = $LabelNode/GameOverNode/GameOverLabel;
	gameOverLabel.hide();
	gameOverNode = $LabelNode/GameOverNode;
	countdownLabel = $LabelNode/CountdownLabel;
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
	GlobalVariables.Player0.connect(GlobalVariables.signalPlayerHasDied, self, "_on_Player0_Dead");
	GlobalVariables.Player1.connect(GlobalVariables.signalPlayerHasDied, self, "_on_Player1_Dead");
	self.add_child_below_node(get_child(1), GlobalVariables.Player0);
	self.add_child_below_node(get_child(1), GlobalVariables.Player1);

func _process(delta):
	if result == -1:
		if (player0HasDied && !GlobalVariables.Player1.call(GlobalVariables.methodIsFalling)) || (player1HasDied && !GlobalVariables.Player0.call(GlobalVariables.methodIsFalling)): 
			drawWaitTime -= delta;
		if player0HasDied && player1HasDied:
			result = Results.Draw;
			showGameOverCountdown();
			return;
		gameOverCountdownLabel.text = String(drawWaitTime);
		if drawWaitTime <= 0:
			result = Results.Player0Won if player1HasDied else Results.Player1Won;
			showGameOverCountdown();
			(GlobalVariables.Player0 if result == Results.Player0Won else GlobalVariables.Player1).call(GlobalVariables.methodGameEnd);
			return;
	else:
		return;

func _physics_process(delta):#Only being used for adding transparency to CountdownLabel for now, change it if needed to be use for other stuff
	countdownLabel.modulate.a -= labelFadeSpeed * delta;

func _on_Timer_timeout():
	if timeBeforeGoTime <= 0:
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
		timer.start(timeBeforeHideCountdownLabel);

func _on_Player0_Dead():
	player0HasDied = true;
	showGameOverCountdownLabelAndEnableProcess();

func _on_Player1_Dead():
	player1HasDied = true;
	showGameOverCountdownLabelAndEnableProcess();

func showGameOverCountdownLabelAndEnableProcess():
	gameOverCountdownLabel.show();
	gameOverCountdownLabel.text = String(drawWaitTime);
	gameOverCountdownLabel.visible_characters = 4;
	set_process(true);

func showGameOverCountdown():
	gameOverCountdownLabel.hide();
	gameOverLabel.show();
	match result:
		Results.Draw:
			gameOverLabel.text = "DRAW";
		Results.Player0Won:
			gameOverLabel.text = GlobalVariables.Player0.name.to_upper() + "\nWINS";
		Results.Player1Won:
			gameOverLabel.text = GlobalVariables.Player1.name.to_upper() + "\nWINS";
