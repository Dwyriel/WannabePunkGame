extends KinematicBody2D;

#Signals
signal player_has_died;

#Export Attributes
export(int) var speed : int;
export(int) var dashMultiplier : int;
export(float) var dashCooldown : float;
export(float) var interpolationSpeed: float = .4;

#Local Attributes
enum States { NotActive, Dead, Alive, Falling, Dashing, BeingPushed };
var CurrentState = States.NotActive;
var DashInput : String;
var RightInput : String;
var LeftInput : String;
var DownInput : String;
var UpInput : String;
var animatedSprite : AnimatedSprite;
var PlayerCollider: CollisionShape2D;
var otherPlayerNode: KinematicBody2D;
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
var character;
var playerInput;

#Godot Functions
func _ready():
	PlayerCollider = $PlayerFeetCollider;
	animatedSprite = $AnimatedSprite;
	timer = $Timer;
	fallingTimer = $FallingTimer;
	dashCooldownTimer = $DashCooldownTimer;
	setPlayerInput();
	setCharacter();
	otherPlayerNode = GlobalVariables.Player0 if playerInput == GlobalVariables.PlayerInput.Player1 else GlobalVariables.Player1;
	PlayerCollider.disabled = false;
	animatedSprite.animation = GlobalVariables.idleAnim;
	animatedSprite.play();

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
func collidedWithOtherPlayer(vec2 : Vector2, isDashing = false):
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

func isFalling():
	return CurrentState == States.Falling;

func receiveInitParams(l_character, l_playerInput):
	self.character = l_character;
	self.playerInput = l_playerInput;

func gameStart():
	switchStateToAlive();

func gameEnd():
	switchStateToNotActive();

#Functions
func setCharacter():
	animatedSprite.frames = GlobalPreloads.SpriteFrameGreen if character == GlobalVariables.Characters.Green else GlobalPreloads.SpriteFrameRed;
	animatedSprite.flip_h = self.position.x >= 0;
	self.name = "Green" if character == GlobalVariables.Characters.Green else "Red" if character == GlobalVariables.Characters.Red else "Yellow";

func setPlayerInput():
	match playerInput:
		GlobalVariables.PlayerInput.Player0:
			DashInput = GlobalVariables.P0_DashInput;
			RightInput = GlobalVariables.P0_RightInput;
			LeftInput = GlobalVariables.P0_LeftInput;
			DownInput = GlobalVariables.P0_DownInput;
			UpInput = GlobalVariables.P0_UpInput;
		GlobalVariables.PlayerInput.Player1:
			DashInput = GlobalVariables.P1_DashInput;
			RightInput = GlobalVariables.P1_RightInput;
			LeftInput = GlobalVariables.P1_LeftInput;
			DownInput = GlobalVariables.P1_DownInput;
			UpInput = GlobalVariables.P1_UpInput;

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
	animatedSprite.scale = Vector2.ONE.linear_interpolate(Vector2.ZERO, interpolation);
	animatedSprite.position.y = 0 + 8 * interpolation; # 0 is the default and 8 is half the amount of pixels one tile and the sprite have.
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
	self.z_index = GlobalVariables.zIndexWhenInFront if position.y > otherPlayerNode.position.y else GlobalVariables.zIndexWhenBehind;

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
		animatedSprite.flip_h = direction.x < 0;
		animatedSprite.animation = GlobalVariables.movingAnim;
	elif direction.y != 0:
		animatedSprite.animation = GlobalVariables.movingAnim;
	else:
		animatedSprite.animation = GlobalVariables.idleAnim;

func dash():
		canDash = false;
		dashCooldownTimer.start(dashCooldown);
		dashDirection = direction;
		if dashDirection.x == 0 && dashDirection.y == 0:
			dashDirection.x = 1 if !animatedSprite.flip_h else -1;
		animatedSprite.flip_h = dashDirection.x < 0;
		switchStateToDashing();

func switchStateToFalling():
	CurrentState = States.Falling;
	PlayerCollider.disabled = true;
	self.z_index = GlobalVariables.zIndexWhenFalling;
	animatedSprite.animation = GlobalVariables.fallingAnim;
	fallingTimer.start(GlobalVariables.fallingTimeBeforeDeath);

func switchStateToAlive():
	CurrentState = States.Alive;
	if !fallingTimer.is_stopped():
		fallingTimer.stop();
	PlayerCollider.disabled = false;
	animatedSprite.scale = Vector2.ONE;
	animatedSprite.position.y = 0;
	interpolation = 0;

func switchStateToDashing():
	CurrentState = States.Dashing;
	PlayerCollider.disabled = false;
	animatedSprite.animation = GlobalVariables.dashingAnim;
	timer.start(GlobalVariables.dashingTime);

func switchStateToBeingPushed():
	CurrentState = States.BeingPushed;
	PlayerCollider.disabled = false;
	animatedSprite.animation = GlobalVariables.beingPushedAnim;
	timer.start(GlobalVariables.BeingPushedTime);

func switchStateToDead():
	CurrentState = States.Dead;
	direction = Vector2.ZERO;
	animatedSprite.hide();
	PlayerCollider.disabled = true;
	emit_signal(GlobalVariables.signalPlayerHasDied);

func switchStateToNotActive():
	CurrentState = States.NotActive;
	animatedSprite.animation = GlobalVariables.idleAnim;
