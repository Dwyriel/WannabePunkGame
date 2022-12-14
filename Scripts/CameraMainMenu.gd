extends Camera2D

#signals
signal zooming_in_complete;
signal zooming_out_complete;

#Exports
export var StartPos : Vector2 = Vector2(800, 450);
export var EndPos : Vector2 = Vector2(620, 340);
export var  StartZoom : Vector2 = Vector2.ONE;
export var EndZoom : Vector2 = Vector2(.28, .28);
export var interpolationSpeed : float = 1;

#Variables
enum CamStates { Idle, ZoomingIn, ZoomingOut }; 
var CurrentCamState = CamStates.Idle;
var interpolation : float = 0;

func _ready():
	pass # Replace with function body.

func _process(delta):
	match CurrentCamState:
		CamStates.Idle:
			return;
		CamStates.ZoomingIn:
			interpolation += delta * interpolationSpeed;
			self.position = StartPos.linear_interpolate(EndPos, interpolation);
			self.position = Vector2(clamp(self.position.x, min(StartPos.x, EndPos.x), max(StartPos.x, EndPos.x)), clamp(self.position.y, min(StartPos.y, EndPos.y), max(StartPos.y, EndPos.y)));
			self.zoom = StartZoom.linear_interpolate(EndZoom, interpolation);
			self.zoom = Vector2(clamp(self.zoom.x, min(StartZoom.x, EndZoom.x), max(StartZoom.x, EndZoom.x)), clamp(self.zoom.y, min(StartZoom.y, EndZoom.y), max(StartZoom.y, EndZoom.y)));
			if self.position.distance_to(EndPos) < 1:
				self.position = EndPos;
				self.zoom = EndZoom;
				emit_signal("zooming_in_complete");
				switchToIdleState();
		CamStates.ZoomingOut:
			interpolation += delta * interpolationSpeed;
			self.position = EndPos.linear_interpolate(StartPos, interpolation);
			self.position = Vector2(clamp(self.position.x, min(StartPos.x, EndPos.x), max(StartPos.x, EndPos.x)), clamp(self.position.y, min(StartPos.y, EndPos.y), max(StartPos.y, EndPos.y)));
			self.zoom = EndZoom.linear_interpolate(StartZoom, interpolation);
			self.zoom = Vector2(clamp(self.zoom.x, min(StartZoom.x, EndZoom.x), max(StartZoom.x, EndZoom.x)), clamp(self.zoom.y, min(StartZoom.y, EndZoom.y), max(StartZoom.y, EndZoom.y)));
			if self.position.distance_to(StartPos) < 1:
				self.position = StartPos;
				self.zoom = StartZoom;
				emit_signal("zooming_out_complete");
				switchToIdleState();

func _on_StartButton_pressed():
	if CurrentCamState == CamStates.Idle:
		switchToZoomingInState();

func _on_ReturnButton_pressed():
	if CurrentCamState == CamStates.Idle:
		switchToZoomingOutState();

#State Control
func switchToZoomingInState():
	CurrentCamState = CamStates.ZoomingIn;
	interpolation = 0;

func switchToZoomingOutState():
	interpolation = 0;
	CurrentCamState = CamStates.ZoomingOut;

func switchToIdleState():
	CurrentCamState = CamStates.Idle;
