extends Button

var label : Label;

func _ready():
	label = $ShadowText;
	label.add_color_override("font_color", GlobalVariables.Purple);

func _on_StartButton_mouse_entered():
	label.add_color_override("font_color", GlobalVariables.Black);# Or.. "label.visible = false;" then "label.visible = true;"

func _on_StartButton_mouse_exited():
	label.add_color_override("font_color", GlobalVariables.Purple);
