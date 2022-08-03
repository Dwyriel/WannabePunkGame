extends KinematicBody2D;

#TODO make state based (dashing, falling, etc)

#Export Attributes
export(int) var speed : int;
export(int) var dashMultiplier : int;
export(float) var dashCooldown : float;
export(float) var scaleDownMultiplier: float;
export(float) var scaleDownOffset: float;

#Local Attributes
enum States {Dead, Alive, Falling, Dashing, BeingPushed }
var CurrentState = States.Alive;
var animationSprite : AnimatedSprite;
var PlayerCollider: CollisionShape2D;
var timer : Timer;
var fallingTimer : Timer;
var dashCooldownTimer : Timer;
var direction : Vector2 = Vector2();
var canMove : bool = true;
var canDash : bool = true;
var outsideOfPlatform : bool = false;

func _ready():
	PlayerCollider = $PlayerFeetCollider;
	animationSprite = $AnimatedSprite;
	timer = $Timer;
	fallingTimer = $FallingTimer;
	dashCooldownTimer = $DashCooldownTimer;
	PlayerCollider.disabled = false;
	animationSprite.animation = GlobalVariables.idleAnim;
	animationSprite.play();
	
func setDirection():
	direction = Vector2();
	if Input.is_action_pressed("ui_right"):
		direction.x += 1;
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1;
	if Input.is_action_pressed("ui_down"):
		direction.y += 1;
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1;

func setAnimation():
	if direction.x != 0:
		animationSprite.flip_h = direction.x < 0;
		animationSprite.animation = GlobalVariables.movingAnim;
	elif direction.y != 0:
		animationSprite.animation = GlobalVariables.movingAnim;
	else:
		animationSprite.animation = GlobalVariables.idleAnim;

func dash(): #TODO make an actual dash, not teleport
		canDash = false;
		dashCooldownTimer.start(dashCooldown);
		var dashDirection: Vector2 = direction;
		if dashDirection.x == 0 && dashDirection.y == 0:
			dashDirection.x = -1 if animationSprite.flip_h else 1;
		var col = move_and_collide(dashDirection.normalized() * dashMultiplier);
		if col != null: # seems to work fine but it might "proc" twice, won't be a problem after script is reworked
			if col.collider.has_method("collided_with_other_player"):
				var push = (col.remainder * -10) + col.collider_velocity;
				move_and_collide(push.normalized() * GlobalVariables.PushBackFromTouchkMultiplier);
				col.collider.call("collided_with_other_player", push * -1, true);

func processStateAlive(delta: float):
	setDirection();
	setAnimation();
	if Input.is_action_pressed(GlobalVariables.dashInput) && canDash:
		dash();
	if outsideOfPlatform:
		switchStateToFalling();
		

func processStateFalling(delta: float):
	setDirection();
	if Input.is_action_pressed(GlobalVariables.dashInput) && canDash:
		dash();
	direction = Vector2.ZERO;
	animationSprite.scale *= scaleDownMultiplier * (1-delta);
	animationSprite.offset.y += scaleDownOffset * (1-delta);
	if !outsideOfPlatform:
		switchStateToAlive();

func _process(delta):
	match CurrentState:
		States.Alive:
			processStateAlive(delta);
		States.Falling:
			processStateFalling(delta);
		_:
			return;

func _physics_process(_delta):
	var col : KinematicCollision2D = move_and_collide(direction.normalized() * speed);
	if col != null: # seems to work fine but it might "proc" twice, won't be a problem after script is reworked
		if col.collider.has_method("collided_with_other_player"):
			var push = (col.remainder * -10) + col.collider_velocity;
			move_and_collide(push.normalized() * 10);
			col.collider.call("collided_with_other_player", push * -1);

func _on_Area2D_body_entered(body : Node):
	if body.name != "TileMap":
		return;
	outsideOfPlatform = false;

func _on_Area2D_body_exited(body):
	if body.name != "TileMap":
		return;
	outsideOfPlatform = true;
	
func _on_FallingTimer_timeout():
	if !outsideOfPlatform:
		return;
	switchStateToDead();
	#TODO stuff when this happens (game over / X player wins / etc)

func _on_DashCooldownTimer_timeout():
	canDash = true;
	
func collided_with_other_player(obj: Vector2, FromDash = false):
	move_and_collide(obj.normalized() * (GlobalVariables.PushBackFromTouchkMultiplier if !FromDash else GlobalVariables.PushBackFromDashMultiplier));

func checkAndSetIfNotOnPlatform():
	if outsideOfPlatform:
		switchStateToFalling();
	elif !outsideOfPlatform:
		switchStateToAlive();

func _on_Timer_timeout():
	match CurrentState:
		States.Dashing:
			checkAndSetIfNotOnPlatform();
		States.BeingPushed:
			checkAndSetIfNotOnPlatform();
		_:
			return;

func switchStateToFalling():
	CurrentState = States.Falling;
	animationSprite.animation = GlobalVariables.fallingAnim;
	fallingTimer.start(GlobalVariables.fallingTimeBeforeDeath);

func switchStateToAlive():
	CurrentState = States.Alive;
	if !fallingTimer.is_stopped():
		fallingTimer.stop();
	animationSprite.scale = Vector2.ONE;
	animationSprite.offset.y = 0;

func switchStateToDashing():
	CurrentState = States.Dashing;
	animationSprite.animation = GlobalVariables.dashingAnim;
	timer.start(GlobalVariables.dashingTime);

func switchStateToBeingPushed():
	CurrentState = States.BeingPushed;
	animationSprite.animation = GlobalVariables.beingPushedAnim;
	timer.start(GlobalVariables.BeingPushedTime);

func switchStateToDead():
	CurrentState = States.Dead;
	direction = Vector2.ZERO;
	animationSprite.hide();
	PlayerCollider.disabled = true;
