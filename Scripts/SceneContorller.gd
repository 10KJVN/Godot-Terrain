# SceneController.gd
extends Node

@export var scene1_path : String = "res://Scenes/main_scene.tscn"
@export var scene2_path : String = "res://Scenes/Scene2.tscn"

var current_scene : Node

func _ready():
	# Load initial scene
	load_scene(scene1_path)
	
	# Enable processing for keyboard input
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("scene_1"):
		load_scene(scene1_path)
	elif event.is_action_pressed("scene_2"):
		load_scene(scene2_path)

func load_scene(path: String):
	# Clean up current scene
	if current_scene:
		current_scene.queue_free()
	
	# Load new scene
	var new_scene = load(path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	print("Switched to: ", path)
