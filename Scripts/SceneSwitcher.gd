extends Node

var currentScene : Node;
var root : Viewport;

func _ready():
	root = get_tree().root;
	currentScene = root.get_child(root.get_child_count()-1);

func goToScene(scene):
	call_deferred("goToSceneIdle", scene);

func goToSceneIdle(scene):
	var nextScene : Node;
	match scene:
		GlobalVariables.GameScenes.Game:
			nextScene = GlobalPreloads.GameScene.instance();
		GlobalVariables.GameScenes.Menu:
			nextScene = GlobalPreloads.MenuScene.instance();
		_:
			return;
	currentScene.free();
	currentScene = nextScene;
	root.add_child(currentScene);
	get_tree().current_scene = currentScene;
