extends KinematicBody2D

#just a temporary script for testing

export(NodePath) var OtherPlayerNodePath;

var velocity : Vector2 = Vector2();
var speed : int = 1;
var otherPlayerNode: Node;

# Called when the node enters the scene tree for the first time.
func _ready():
	otherPlayerNode = get_node(OtherPlayerNodePath);

func _process(delta):
	self.z_index = 2 if position.y > otherPlayerNode.position.y else 1;
	velocity = Vector2();
	if Input.is_action_pressed("right"):
		velocity.x += 1;
	if Input.is_action_pressed("left"):
		velocity.x -= 1;
	if Input.is_action_pressed("down"):
		velocity.y += 1;
	if Input.is_action_pressed("up"):
		velocity.y -= 1;

func _physics_process(_delta):
	var col : KinematicCollision2D = move_and_collide(velocity.normalized() * speed);
	if col != null:
		if col.collider.has_method("collided_with_other_player"):
			var push = (col.remainder * -10) + col.collider_velocity;
			move_and_collide(push.normalized() * 10);
			col.collider.call("collided_with_other_player", push * -1);

func collided_with_other_player(obj: Vector2, FromDash = false):
	move_and_collide(obj.normalized() * (GlobalVariables.PushBackFromTouchkMultiplier if !FromDash else GlobalVariables.PushBackFromDashMultiplier));
