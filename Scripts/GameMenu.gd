extends Control

onready var returnButton = $ReturnButton;
onready var redCharacterButton = $RedCharacterButton;
onready var greenCharacterButton = $GreenCharacterButton;
var startButtonShadow;
var exitButtonShadow;

func _ready():
	GlobalVariables.currentGameScene = GlobalVariables.GameScenes.Menu;
	returnButton.visible = false;
	redCharacterButton.visible = false;
	greenCharacterButton.visible = false;
	startButtonShadow = $StartButton.get_node("ShadowText");
	exitButtonShadow = $ExitButton.get_node("ShadowText");
	startButtonShadow.add_color_override("font_color", GlobalVariables.Purple);
	exitButtonShadow.add_color_override("font_color", GlobalVariables.Purple);

func _on_StartButton_mouse_entered():
	startButtonShadow.add_color_override("font_color", GlobalVariables.Black);# Or.. "label.visible = false;" then "label.visible = true;"

func _on_StartButton_mouse_exited():
	startButtonShadow.add_color_override("font_color", GlobalVariables.Purple);

func _on_ExitButton_mouse_entered():
	exitButtonShadow.add_color_override("font_color", GlobalVariables.Black);

func _on_ExitButton_mouse_exited():
	exitButtonShadow.add_color_override("font_color", GlobalVariables.Purple);

func _on_ExitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST);

func _on_Camera2D_zooming_in_complete():
	returnButton.visible = true;
	redCharacterButton.visible = true;
	greenCharacterButton.visible = true;

func _on_Camera2D_zooming_out_complete():
	redCharacterButton.visible = false;
	greenCharacterButton.visible = false;

func _on_ReturnButton_pressed():
	returnButton.visible = false;

func _on_GreenCharacterButton_pressed():
	GlobalVariables.Player0 = GlobalVariables.Characters.Green;
	GlobalVariables.Player1 = GlobalVariables.Characters.Red; #when there's more characters, we could randomize
	SceneSwitcher.goToScene(GlobalVariables.GameScenes.Game);

func _on_RedCharacterButton_pressed():
	GlobalVariables.Player0 = GlobalVariables.Characters.Red;
	GlobalVariables.Player1 = GlobalVariables.Characters.Green;
	SceneSwitcher.goToScene(GlobalVariables.GameScenes.Game);
