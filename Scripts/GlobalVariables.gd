extends Node

enum GameScenes {Menu, Game}
var currentGameScene;
var PushBackFromTouchkMultiplier: float = 60;
var PushBackFromDashMultiplier: float = 120;
var BeingPushedTime: float = .15; #! Some of those can(should?) be moved to the player script, for more customization &&/|| different attributes/skills for each character
var dashingTime: float = .2;
var fallingTimeBeforeDeath: float = 2;
var zIndexInFront : int = 3;
var zIndexInBehind : int = 2;
var zIndexInFalling : int = 1;

enum Characters {Green, Red, Yellow};
var Player0;
var Player1;

#Input String Names:
const P0_DashInput : String = "P0_Dash";
const P0_RightInput : String = "P0_Right";
const P0_LeftInput : String = "P0_Left";
const P0_DownInput : String = "P0_Down";
const P0_UpInput : String = "P0_Up";
const P1_DashInput : String = "P1_Dash";
const P1_RightInput : String = "P1_Right";
const P1_LeftInput : String = "P1_Left";
const P1_DownInput : String = "P1_Down";
const P1_UpInput : String = "P1_Up";

#Animation String Names:
const beingPushedAnim : String = "beingPushed";
const dashingAnim : String = "dashing";
const idleAnim : String = "idle";
const movingAnim : String = "moving";
const fallingAnim : String = "falling";

#Method String Names:
const methodCollidedWithOtherPlayer : String = "collided_with_other_player";
const methodIsDashing : String = "isDashing"
const methodSetExternalAttributes : String = "setExternalAttributes";
const methodGameStart : String = "gameStart";

#Pallete Colors:
const White : Color = Color("#FFF1E8");
const Black : Color = Color("#000000");
const Purple : Color = Color("#7E2553");
const Pink : Color = Color("#FF77A8");
const Brown : Color = Color("#AB5236");
const DarkBlue : Color = Color("#1D2B53");
const DarkGreen : Color = Color("#008751");
const LightGrey : Color = Color("#C2C3C7");
const LightGreen : Color = Color("#00E436");
const LightBlue : Color = Color("#29ADFF");

class PlayerAttributes:
	var DashInput : String;
	var RightInput : String;
	var LeftInput : String;
	var DownInput : String;
	var UpInput : String;
	var InitialPos : Vector2;
	var SpriteFrame : SpriteFrames; 
	var OtherPlayerNode : KinematicBody2D;
	var shouldFlipSprite : bool;
	
	func _custom_init(DashInput : String, RightInput : String, LeftInput : String, DownInput : String, UpInput : String, InitialPos : Vector2, SpriteFrame : SpriteFrames, OtherPlayerNode : KinematicBody2D, shouldFlipSprite):
		self.DashInput = DashInput;
		self.RightInput = RightInput;
		self.LeftInput = LeftInput;
		self.DownInput = DownInput;
		self.UpInput = UpInput;
		self.InitialPos = InitialPos;
		self.SpriteFrame = SpriteFrame;
		self.OtherPlayerNode = OtherPlayerNode;
		self.shouldFlipSprite = shouldFlipSprite;
