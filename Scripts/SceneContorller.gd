extends Node

@export var scene1_path : String = "res://Scenes/main_scene.tscn"
@export var scene2_path : String = "res://Scenes/Scene2.tscn"
@export var loading_screen : PackedScene
@export var min_loading_time : float = 2.0  # Minimum seconds to show loading screen

var current_scene : Node
var loading_screen_instance : Control

func _ready():
	# Start with scene 1
	current_scene = load(scene1_path).instantiate()
	add_child(current_scene)

func _input(event):
	if event.is_action_pressed("scene_1") and (not current_scene or current_scene.scene_file_path != scene1_path):
		_switch_scene(scene1_path)
	elif event.is_action_pressed("scene_2") and (not current_scene or current_scene.scene_file_path != scene2_path):
		_switch_scene(scene2_path)

func _switch_scene(path: String):
	# Show loading screen immediately
	loading_screen_instance = loading_screen.instantiate()
	add_child(loading_screen_instance)
	
	# Start tracking time
	var load_start_time = Time.get_ticks_msec()
	
	# Load the new scene (blocking operation)
	var new_scene = load(path).instantiate()
	
	# Calculate remaining time to reach minimum duration
	var load_time = (Time.get_ticks_msec() - load_start_time) / 1000.0
	var remaining_wait = max(0, min_loading_time - load_time)
	
	# Wait remaining time if needed
	if remaining_wait > 0:
		await get_tree().create_timer(remaining_wait).timeout
	
	# Scene transition
	if current_scene:
		current_scene.queue_free()
	add_child(new_scene)
	current_scene = new_scene
	
	# Remove loading screen
	loading_screen_instance.queue_free()
