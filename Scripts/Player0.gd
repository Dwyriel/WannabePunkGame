extends KinematicBody2D;

#Attributes
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
		move_and_slide(dashDirection.normalized() * dashMultiplier);

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
		animationSprite.scale *= 0.9999 * (1-delta); #TODO get rid of magic number
		animationSprite.offset.y += .1 * (1-delta);
	else:
		animationSprite.scale = Vector2(1, 1);
		animationSprite.offset.y = 0;

func _physics_process(_delta):
	move_and_collide(velocity.normalized() * speed);

func _on_Area2D_body_entered(body):
	print_debug("Body entered: " + body.name);
	canMove = true;
	outsideOfPlatform = false;
	if !fallingTimer.is_stopped():
		fallingTimer.stop()

func _on_Area2D_body_exited(body):
	print_debug("Body exited: " + body.name);
	animationSprite.animation = "idle"; #Need falling animation
	canMove = false;
	outsideOfPlatform = true;
	fallingTimer.start(2);
	
func _on_FallingTimer_timeout():
	isAlive = false;
	velocity = Vector2();

func _on_DashCooldownTimer_timeout():
	canDash = true;
