extends Node2D

signal character_selected(character);

var isMouseHovering : bool = false;

onready var sprite : Sprite = get_node("Sprite");

func _on_KinematicBody2D_mouse_entered():
	isMouseHovering = true;
	sprite.material.set("shader_param/lineThickness", .5);


func _on_KinematicBody2D_mouse_exited():
	isMouseHovering = false;
	sprite.material.set("shader_param/lineThickness", .0);


func _on_KinematicBody2D_input_event(viewport : Node, event : InputEvent, shape_idx):
	if event is InputEventMouseButton && !event.is_pressed() && event.button_index == BUTTON_LEFT: #inverting event.is_pressed() so it only counts when button is released
		match self.name:
			"GreenPortrait":
				emit_signal("characterSelected", GlobalVariables.Characters.Green);
			"RedPortrait":
				emit_signal("characterSelected", GlobalVariables.Characters.Red);
			_:
				return;
