extends KinematicBody2D


var velocity : Vector2 = Vector2();
var speed : int = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	velocity = Vector2();
	if Input.is_action_pressed("right"):
		velocity.x += 1;
	if Input.is_action_pressed("left"):
		velocity.x -= 1;
	if Input.is_action_pressed("down"):
		velocity.y += 1;
	if Input.is_action_pressed("up"):
		velocity.y -= 1;

var waspushed: bool = false;
var coli : KinematicCollision2D;
func _physics_process(_delta):
	var col : KinematicCollision2D = move_and_collide(velocity.normalized() * speed);
	if coli != null && waspushed:
		var push = (coli.remainder * -10) + coli.collider_velocity;
		move_and_collide(push.normalized() * 10);
		waspushed = false;
		coli = null;
	if col != null:
		waspushed = true;
		coli = col;
