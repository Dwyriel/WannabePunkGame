extends KinematicBody2D;

#Export Attributes
export(int) var speed : int;
export(int) var dashMultiplier : int;
export(float) var dashCooldown : float;
export(float) var interpolationSpeed: float = .4;

#Local Attributes
enum States { NotActive, Dead, Alive, Falling, Dashing, BeingPushed };
var CurrentState = States.NotActive;
var animationSprite : AnimatedSprite;
var PlayerCollider: CollisionShape2D;
var timer : Timer;
var fallingTimer : Timer;
var dashCooldownTimer : Timer;
var direction : Vector2 = Vector2.ZERO;
var dashDirection: Vector2 = Vector2.RIGHT;
var pushDirection: Vector2 = Vector2.ZERO;
var canDash : bool = true;
var outsideOfPlatform : bool = false;
var pushedFromDash: bool = false;
var interpolation = 0;

#External Attributes (Comes from some other script)
var DashInput : String;
var RightInput : String;
var LeftInput : String;
var DownInput : String;
var UpInput : String;
var otherPlayerNode: KinematicBody2D;

#Godot Functions
func _ready():
	PlayerCollider = $PlayerFeetCollider;
	animationSprite = $AnimatedSprite;
	timer = $Timer;
	fallingTimer = $FallingTimer;
	dashCooldownTimer = $DashCooldownTimer;
	PlayerCollider.disabled = false;
	animationSprite.animation = GlobalVariables.idleAnim;
	animationSprite.play();

func _process(delta):
	match CurrentState:
		States.Alive:
			processStateAlive(delta);
		States.Falling:
			processStateFalling(delta);
		States.Dashing:
			processStateDashing(delta);
		States.BeingPushed:
			processStateBeingPushed(delta);
		_:
			return;

func _physics_process(delta):
	match CurrentState:
		States.Alive: 
			physicsProcessStateAlive(delta);
		States.Dashing:
			physicsProcessStateDashing(delta);
		States.BeingPushed:
			physicsProcessStateBeingPushed(delta)
		_:
			return;

#Event Functions
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

func _on_Timer_timeout():
	validadePosition();

#"Public" Functions (called from outside)
func collided_with_other_player(vec2 : Vector2, isDashing = false):
	match CurrentState:
		States.Dashing:
			if !isDashing:
				return;
			else:
				continue;
		_:
			pushedFromDash = isDashing;
			pushDirection = vec2;
			switchStateToBeingPushed();

func isDashing():
	return CurrentState == States.Dashing;

func setExternalAttributes(attributes: GlobalVariables.PlayerAttributes):
	DashInput = attributes.DashInput;
	RightInput = attributes.RightInput;
	LeftInput = attributes.LeftInput;
	DownInput = attributes.DownInput;
	UpInput = attributes.UpInput;
	self.position = attributes.InitialPos;
	$AnimatedSprite.frames = attributes.SpriteFrame; #needs to be set directly, as the variable "animatedSprite" is still null at this point
	otherPlayerNode = attributes.OtherPlayerNode;
	$AnimatedSprite.flip_h = attributes.shouldFlipSprite;

func gameStart():
	switchStateToAlive();

#Functions
func validadePosition():
	if outsideOfPlatform:
		switchStateToFalling();
	elif !outsideOfPlatform:
		switchStateToAlive();

func processStateAlive(delta: float):
	setZIndex();
	setDirection();
	setAnimation();
	if Input.is_action_pressed(DashInput) && canDash:
		dash();
	if outsideOfPlatform:
		switchStateToFalling();

func processStateFalling(delta: float):
	setDirection();
	if Input.is_action_pressed(DashInput) && canDash:
		dash();
	direction = Vector2.ZERO;
	interpolation += interpolationSpeed * delta;
	animationSprite.scale = Vector2.ONE.linear_interpolate(Vector2.ZERO, interpolation);
	animationSprite.position.y = 0 + 8 * interpolation; # 0 is the default and 8 is half the amount of pixels one tile and the sprite have.
	if !outsideOfPlatform:
		switchStateToAlive();

func processStateDashing(delta: float):
	setZIndex();

func processStateBeingPushed(delta: float):
	setZIndex();
	if Input.is_action_pressed(DashInput) && canDash:
		dash();

func physicsProcessStateAlive(delta: float):
	var collision : KinematicCollision2D = move_and_collide(direction.normalized() * speed * delta);
	if collision != null: 
		if collision.collider.has_method(GlobalVariables.methodCollidedWithOtherPlayer) && collision.collider.has_method(GlobalVariables.methodIsDashing):
			pushDirection = collision.remainder * -1;
			pushedFromDash = collision.collider.call(GlobalVariables.methodIsDashing);
			switchStateToBeingPushed();
			collision.collider.call(GlobalVariables.methodCollidedWithOtherPlayer, collision.remainder);

func physicsProcessStateDashing(delta: float):
	var collision = move_and_collide(dashDirection.normalized() * dashMultiplier * delta);
	if collision != null:
		if collision.collider.has_method(GlobalVariables.methodCollidedWithOtherPlayer) && collision.collider.has_method(GlobalVariables.methodIsDashing):
			var isDashing : bool = collision.collider.call(GlobalVariables.methodIsDashing);
			if isDashing:
				pushDirection = collision.remainder * -1;
				pushedFromDash = isDashing;
				switchStateToBeingPushed();
			collision.collider.call(GlobalVariables.methodCollidedWithOtherPlayer, collision.remainder, true);

func physicsProcessStateBeingPushed(delta: float):
	move_and_collide(pushDirection.normalized() * (GlobalVariables.PushBackFromTouchkMultiplier if !pushedFromDash else GlobalVariables.PushBackFromDashMultiplier) * delta);

func setZIndex():
	self.z_index = GlobalVariables.zIndexInFront if position.y > otherPlayerNode.position.y else GlobalVariables.zIndexInBehind;

func setDirection():
	direction = Vector2();
	if Input.is_action_pressed(RightInput):
		direction.x += 1;
	if Input.is_action_pressed(LeftInput):
		direction.x -= 1;
	if Input.is_action_pressed(DownInput):
		direction.y += 1;
	if Input.is_action_pressed(UpInput):
		direction.y -= 1;

func setAnimation():
	if direction.x != 0:
		animationSprite.flip_h = direction.x < 0;
		animationSprite.animation = GlobalVariables.movingAnim;
	elif direction.y != 0:
		animationSprite.animation = GlobalVariables.movingAnim;
	else:
		animationSprite.animation = GlobalVariables.idleAnim;

func dash():
		canDash = false;
		dashCooldownTimer.start(dashCooldown);
		dashDirection = direction;
		if dashDirection.x == 0 && dashDirection.y == 0:
			dashDirection.x = 1 if !animationSprite.flip_h else -1;
		animationSprite.flip_h = dashDirection.x < 0;
		switchStateToDashing();

func switchStateToFalling():
	CurrentState = States.Falling;
	PlayerCollider.disabled = true;
	self.z_index = GlobalVariables.zIndexInFalling;
	animationSprite.animation = GlobalVariables.fallingAnim;
	fallingTimer.start(GlobalVariables.fallingTimeBeforeDeath);

func switchStateToAlive():
	CurrentState = States.Alive;
	if !fallingTimer.is_stopped():
		fallingTimer.stop();
	PlayerCollider.disabled = false;
	animationSprite.scale = Vector2.ONE;
	animationSprite.position.y = 0;
	interpolation = 0;

func switchStateToDashing():
	CurrentState = States.Dashing;
	PlayerCollider.disabled = false;
	animationSprite.animation = GlobalVariables.dashingAnim;
	timer.start(GlobalVariables.dashingTime);

func switchStateToBeingPushed():
	CurrentState = States.BeingPushed;
	PlayerCollider.disabled = false;
	animationSprite.animation = GlobalVariables.beingPushedAnim;
	timer.start(GlobalVariables.BeingPushedTime);

func switchStateToDead():
	CurrentState = States.Dead;
	direction = Vector2.ZERO;
	animationSprite.hide();
	PlayerCollider.disabled = true;
