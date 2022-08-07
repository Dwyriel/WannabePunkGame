extends KinematicBody2D;

#Export Attributes
export(int) var speed : int;
export(int) var dashMultiplier : int;
export(float) var dashCooldown : float;
export(float) var scaleDownMultiplier: float;
export(float) var scaleDownOffset: float;
export(NodePath) var OtherPlayerNodePath;

#Local Attributes
enum States { Dead, Alive, Falling, Dashing, BeingPushed };
var CurrentState = States.Alive;
var otherPlayerNode: Node;
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
	otherPlayerNode = get_node(OtherPlayerNodePath);

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

func collided_with_other_player(vec2 : Vector2, isDashing = false):
	match CurrentState:
		States.Dashing:
			return;
		_:
			pushedFromDash = isDashing;
			pushDirection = vec2;
			switchStateToBeingPushed();

func isDashing():
	return CurrentState == States.Dashing;
	
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
	if Input.is_action_pressed(GlobalVariables.dashInput) && canDash:
		dash();
	if outsideOfPlatform:
		switchStateToFalling();

func processStateFalling(delta: float):
	setDirection();
	if Input.is_action_pressed(GlobalVariables.dashInput) && canDash:
		dash();
	direction = Vector2.ZERO;
	animationSprite.scale *= (1 - delta) * scaleDownMultiplier;
	animationSprite.offset.y += delta * scaleDownOffset;
	if !outsideOfPlatform:
		switchStateToAlive();

func processStateDashing(delta: float):
	setZIndex();

func processStateBeingPushed(delta: float):
	setZIndex();
	if Input.is_action_pressed(GlobalVariables.dashInput) && canDash:
		dash();

func physicsProcessStateAlive(delta: float):
	var col : KinematicCollision2D = move_and_collide(direction.normalized() * speed * delta);
	if col != null: 
		if col.collider.has_method(GlobalVariables.collidedWithOtherPlayerMethod) && col.collider.has_method(GlobalVariables.isDashingMethod):
			var push = (col.remainder * -10) + col.collider_velocity;
			col.collider.call(GlobalVariables.collidedWithOtherPlayerMethod, col.remainder);
			pushDirection = col.remainder * -1;
			pushedFromDash = col.collider.call(GlobalVariables.isDashingMethod);
			switchStateToBeingPushed();

func physicsProcessStateDashing(delta: float):
	var col = move_and_collide(dashDirection.normalized() * dashMultiplier * delta);
	if col != null:
		if col.collider.has_method(GlobalVariables.collidedWithOtherPlayerMethod):
			col.collider.call(GlobalVariables.collidedWithOtherPlayerMethod, col.remainder, true);

func physicsProcessStateBeingPushed(delta: float):
	move_and_collide(pushDirection.normalized() * (GlobalVariables.PushBackFromTouchkMultiplier if !pushedFromDash else GlobalVariables.PushBackFromDashMultiplier) * delta);

func setZIndex():
	self.z_index = GlobalVariables.zIndexInFront if position.y > otherPlayerNode.position.y else GlobalVariables.zIndexInBehind;

func setDirection():
	direction = Vector2();
	if Input.is_action_pressed(GlobalVariables.uiRightInput):
		direction.x += 1;
	if Input.is_action_pressed(GlobalVariables.uiLeftInput):
		direction.x -= 1;
	if Input.is_action_pressed(GlobalVariables.uiDownInput):
		direction.y += 1;
	if Input.is_action_pressed(GlobalVariables.uiUpInput):
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
	animationSprite.offset.y = 0;

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
