extends Sprite

export(float) var minDistanceForBlueColor : float = 15; 

var interpolation = 0;

func _ready():
	if minDistanceForBlueColor > GlobalVariables.DistanceMinPull:
		minDistanceForBlueColor = GlobalVariables.DistanceMinPull;

#Important: "self.scale.x" is the exact distance between player0 and player1 and should be read as "distance" when not being assigned;
func _process(delta):
	self.visible = !GlobalVariables.Player0.call(GlobalVariables.methodIsFalling) && !GlobalVariables.Player1.call(GlobalVariables.methodIsFalling)
	self.position = GlobalVariables.Player0.position - Vector2(0, -2.5);
	self.scale.x = GlobalVariables.Player0.position.distance_to(GlobalVariables.Player1.position);
	self.rotation = (GlobalVariables.Player1.position - GlobalVariables.Player0.position).angle();
	interpolation = clamp((self.scale.x - minDistanceForBlueColor) / (GlobalVariables.DistanceMinPull - minDistanceForBlueColor) if self.scale.x < GlobalVariables.DistanceMinPull else (self.scale.x - GlobalVariables.DistanceMinPull) / (GlobalVariables.DistanceMaxPull - GlobalVariables.DistanceMinPull), 0 ,1)
	self.modulate = GlobalVariables.LightBlue.linear_interpolate(GlobalVariables.White, interpolation) if self.scale.x < GlobalVariables.DistanceMinPull else GlobalVariables.White.linear_interpolate(GlobalVariables.Red, interpolation)

func _on_MainNode_playersHaveBeenCreated():
	GlobalVariables.Player0.connect(GlobalVariables.signalPlayerHasDied, self, "_on_Player0_Dead");
	GlobalVariables.Player1.connect(GlobalVariables.signalPlayerHasDied, self, "_on_Player1_Dead");

func _on_Player0_Dead():
	set_process(false);
	self.visible = false;

func _on_Player1_Dead():
	set_process(false);
	self.visible = false;
