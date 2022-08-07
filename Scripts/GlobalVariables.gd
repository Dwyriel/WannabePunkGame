extends Node

enum GameStates {Menu, Ingame, Gameover}
enum Characters {Green, Red, Yellow}
var GameState = GameStates.Menu;
var PushBackFromTouchkMultiplier: float = 60;
var PushBackFromDashMultiplier: float = 120;
var BeingPushedTime: float = .15; #! Some of those can(should?) be moved to the player script, for more customization &&/|| different attributes/skills for each character
var dashingTime: float = .2;
var fallingTimeBeforeDeath: float = 2;
var zIndexInFront : int = 3;
var zIndexInBehind : int = 2;
var zIndexInFalling : int = 1;

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
const beingPushedAnim = "beingPushed";
const dashingAnim : String = "dashing";
const idleAnim : String = "idle";
const movingAnim : String = "moving";
const fallingAnim : String = "falling";

#Method String Names:
const collidedWithOtherPlayerMethod : String = "collided_with_other_player";
const isDashingMethod : String = "isDashing"

class PlayerAttributes:
	var DashInput : String;
	var RightInput : String;
	var LeftInput : String;
	var DownInput : String;
	var UpInput : String;
	var InitialPos : Vector2;
	var SpriteFrame : SpriteFrames; 
	var OtherPlayerNode : Node;
	var shouldFlipSprite : bool;
	
	func _custom_init(DashInput : String, RightInput : String, LeftInput : String, DownInput : String, UpInput : String, InitialPos : Vector2, SpriteFrame : SpriteFrames, OtherPlayerNode : Node, shouldFlipSprite):
		self.DashInput = DashInput;
		self.RightInput = RightInput;
		self.LeftInput = LeftInput;
		self.DownInput = DownInput;
		self.UpInput = UpInput;
		self.InitialPos = InitialPos;
		self.SpriteFrame = SpriteFrame;
		self.OtherPlayerNode = OtherPlayerNode;
		self.shouldFlipSprite = shouldFlipSprite;
