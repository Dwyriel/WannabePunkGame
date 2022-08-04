extends Node

enum GameStates {Menu, Ingame, Gameover}
var GameState = GameStates.Menu;
var PushBackFromTouchkMultiplier: float = 60;
var PushBackFromDashMultiplier: float = 120;
var BeingPushedTime: float = .15;
var dashingTime: float = .2;
var fallingTimeBeforeDeath: float = 2;
var zIndexInFront : int = 3;
var zIndexInBehind : int = 2;
var zIndexInFalling : int = 1;

#Input String Names:
const dashInput : String = "Dash";
const uiRightInput : String = "ui_right";
const uiLeftInput : String = "ui_left";
const uiDownInput : String = "ui_down";
const uiUpInput : String = "ui_up";

#Animation String Names:
const beingPushedAnim = "beingPushed";
const dashingAnim : String = "dashing";
const idleAnim : String = "idle";
const movingAnim : String = "moving";
const fallingAnim : String = "falling";

#Method String Names:
const collidedWithOtherPlayerMethod : String = "collided_with_other_player";
const isDashingMethod : String = "isDashing"
