extends Control

func _ready():
	%ProgressBar.value = 0
	ResourceLoader.load_threaded_request("res://main_scene.tscn")

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status("res://main_scene.tscn", progress)
	%ProgressBar.value = progress[0] * 100
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://main_scene.tscn"))
