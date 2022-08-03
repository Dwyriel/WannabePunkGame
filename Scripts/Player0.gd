extends KinematicBody2D;

#TODO make state based (dashing, falling, etc)

#Attributes
export(float) var scaleDownMultiplier: float;
export(float) var scaleDownOffset: float;
export(int) var speed : int;
export(int) var dashMultiplier : int;
export(float) var dashCooldown : float;
var animationSprite : AnimatedSprite;
var fallingTimer : Timer;
var dashCooldownTimer : Timer;
var velocity : Vector2 = Vector2();
var canMove : bool = true;
var canDash : bool = true;
var isAlive : bool = true;
var outsideOfPlatform : bool = false;

func setVelocity(delta : float):
	velocity = Vector2();
	if canMove:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1;
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1;
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1;
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1;

func setAnimation():
	if velocity.x != 0:
		animationSprite.flip_h = velocity.x < 0;
		animationSprite.animation = "moving";
	elif velocity.y != 0:
		animationSprite.animation = "moving";
	else:
		animationSprite.animation = "idle";

func dash(): #TODO make an actual dash, not teleport
		canDash = false;
		dashCooldownTimer.start(dashCooldown);
		var dashDirection: Vector2;
		if velocity.x == 0 && velocity.y == 0:
			if Input.is_action_pressed("ui_right"):
				dashDirection.x += 1;
			if Input.is_action_pressed("ui_left"):
				dashDirection.x -= 1;
			if Input.is_action_pressed("ui_down"):
				dashDirection.y += 1;
			if Input.is_action_pressed("ui_up"):
				dashDirection.y -= 1;
		else:
			dashDirection = velocity;
		if dashDirection.x == 0 && dashDirection.y == 0:
			dashDirection.x = -1 if animationSprite.flip_h else 1;
		var col = move_and_collide(dashDirection.normalized() * dashMultiplier);
		if col != null: # seems to work fine but it might "proc" twice, won't be a problem after script is reworked
			if col.collider.has_method("collided_with_other_player"):
				var push = (col.remainder * -10) + col.collider_velocity;
				move_and_collide(push.normalized() * 10);
				col.collider.call("collided_with_other_player", push * -1);

func _ready():
	animationSprite = $AnimatedSprite;
	animationSprite.play();
	fallingTimer = $FallingTimer;
	dashCooldownTimer = $DashCooldownTimer;

func _process(delta):
	if !isAlive:
		return;
	setVelocity(delta);
	setAnimation();
	
	if Input.is_action_just_pressed("Dash") && canDash:
		dash();
	
	if outsideOfPlatform:
		animationSprite.scale *= scaleDownMultiplier * (1-delta);
		animationSprite.offset.y += scaleDownOffset * (1-delta);
	else:
		animationSprite.scale = Vector2(1, 1);
		animationSprite.offset.y = 0;

func _physics_process(_delta):
	var col : KinematicCollision2D = move_and_collide(velocity.normalized() * speed);
	if col != null: # seems to work fine but it might "proc" twice, won't be a problem after script is reworked
		if col.collider.has_method("collided_with_other_player"):
			var push = (col.remainder * -10) + col.collider_velocity;
			move_and_collide(push.normalized() * 10);
			col.collider.call("collided_with_other_player", push * -1);

func _on_Area2D_body_entered(body : Node):
	if body.name != "TileMap":
		return;
	canMove = true;
	outsideOfPlatform = false;
	if !fallingTimer.is_stopped():
		fallingTimer.stop()

func _on_Area2D_body_exited(body):
	if body.name != "TileMap":
		return;
	animationSprite.animation = "idle"; #Need falling animation
	canMove = false;
	outsideOfPlatform = true;
	fallingTimer.start(2);
	
func _on_FallingTimer_timeout():
	isAlive = false;
	velocity = Vector2();
	animationSprite.hide();
	#TODO stuff when this happens (game over / X player wins / etc)

func _on_DashCooldownTimer_timeout():
	canDash = true;
	
func collided_with_other_player(obj: Vector2):
	move_and_collide(obj.normalized() * 10);
