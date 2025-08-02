# SceneController.gd
extends Node

@export var scene1_path : String = "res://Scenes/main_scene.tscn"
@export var scene2_path : String = "res://Scenes/Scene2.tscn"
@export var loading_screen : PackedScene # Assign scene in - inspector

var current_scene : Node
var loading_screen_instance : Control

func _ready():
	# Load initial scene
	load_scene(scene1_path)
	
	# Enable processing for keyboard input
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("scene_1") and current_scene.filename != scene1_path:
		show_loading_screen()
		await load_scene_async(scene1_path)

	elif event.is_action_pressed("scene_2") and current_scene.filename != scene2_path:
		load_scene(scene2_path) and current_scene.filename != scene2_path
		show_loading_screen()
		await load_scene_async(scene2_path)

func show_loading_screen():
	loading_screen_instance = loading_screen.instantiate()
	add_child(loading_screen_instance)

func hide_loading_screen():
	if loading_screen_instance:
		loading_screen_instance.queue_free()
		loading_screen_instance = null

func load_scene_async(path: String):
	ResourceLoader.load_threaded_request(path)
	
	while true:
		var progress = []
		var status = ResourceLoader.load_threated_get_status(path, progress)
		
		if loading_screen_instance.has_node("ProgressBar"):
			loading_screen_instance.get_node("Progressbar").value = progress[0] * 100
	
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		await get_tree().process_frame
	
	if current_scene:
		current_scene.queue_free()
	
	var new_scene = ResourceLoader.load_threaded_get(path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	hide_loading_screen()

func load_scene(path: String):
	# Clean up current scene
	if current_scene:
		current_scene.queue_free()
	
	# Load new scene
	var new_scene = load(path).instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	print("Switched to: ", path)
