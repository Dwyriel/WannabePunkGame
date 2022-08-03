extends Node

enum GameStates {Menu, Ingame, Gameover}
var GameState = GameStates.Menu;
var PushBackFromTouchkMultiplier: float = 10;
var PushBackFromDashMultiplier: float = 20;
var BeingPushedTime: float = .4;
var dashingTime: float = .5;
var fallingTimeBeforeDeath: float = 2;

#Input String Names:
const dashInput = "Dash";

#Animation String Names:
const beingPushedAnim = "beingPushed";
const dashingAnim = "dashing";
const idleAnim = "idle";
const movingAnim = "moving";
const fallingAnim = "falling";
