extends Control

var startButtonShadow;
var exitButtonShadow;

func _ready():
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

func _on_StartButton_pressed():
	SceneSwitcher.goToScene(GlobalVariables.GameScenes.Game);

func _on_ExitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST);
