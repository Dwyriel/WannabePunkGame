extends Node

enum GameScenes {Menu, Game}
var currentGameScene;
var PushBackFromTouchkMultiplier: float = 60;
var PushBackFromDashMultiplier: float = 120;
var BeingPushedTime: float = .15; #! Some of those can(should?) be moved to the player script, for more customization &&/|| different attributes/skills for each character
var dashingTime: float = .2;
var fallingTimeBeforeDeath: float = 2;
var zIndexWhenInFront : int = 3;
var zIndexWhenBehind : int = 2;
var zIndexWhenFalling : int = 1;

enum Characters { Green, Red, Yellow };
enum PlayerInput { Player0, Player1 };
var CharacterPicked = Characters.Green;

var Player0 : KinematicBody2D;
var Player1 : KinematicBody2D;

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

#Methods/Signals String Names:
const methodCollidedWithOtherPlayer : String = "collidedWithOtherPlayer";
const methodIsDashing : String = "isDashing";
const methodIsFalling : String = "isFalling";
const methodreceiveInitParams : String = "receiveInitParams";
const methodGameStart : String = "gameStart";
const methodGameEnd : String = "gameEnd";
const signalPlayerHasDied : String = "player_has_died";

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
