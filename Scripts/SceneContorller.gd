# SceneController.gd
extends Node

@export var scene1_path : String = "res://Scenes/main_scene.tscn"
@export var scene2_path : String = "res://Scenes/Scene2.tscn"
@export var loading_screen : PackedScene # Assign your loading_screen.tscn

var current_scene : Node
var loading_screen_instance : Control

func _ready():
	# Start with scene 1 using immediate load
	current_scene = load(scene1_path).instantiate()
	add_child(current_scene)

func _input(event):
	if event.is_action_pressed("scene_1") and current_scene.scene_file_path != scene1_path:
		_switch_scene(scene1_path)
	elif event.is_action_pressed("scene_2") and current_scene.scene_file_path != scene2_path:
		_switch_scene(scene2_path)

func _switch_scene(path: String):
	# Show loading screen (must have at least TextureRect)
	loading_screen_instance = loading_screen.instantiate()
	add_child(loading_screen_instance)
	
	# Force redraw to actually show loading screen
	await get_tree().process_frame
	
	# Load new scene (blocking but with loading screen visible)
	var new_scene = load(path).instantiate()
	
	# Remove old scene
	if current_scene:
		current_scene.queue_free()
	
	# Add new scene
	add_child(new_scene)
	current_scene = new_scene
	
	# Remove loading screen after brief delay (optional)
	await get_tree().create_timer(0.5).timeout
	loading_screen_instance.queue_free()
