extends Object

static func preprocess_shader(path: String, include_dir: String = "res://shaders/includes/") -> String:
	var shader_code := ""

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open shader file: " + path)
		return ""

	var include_regex := RegEx.new()
	include_regex.compile("#include\\s+\"([^\"]+)\"")

	while not file.eof_reached():
		var line := file.get_line().strip_edges()

		if line.begins_with("#include"):
			var result := include_regex.search(line)
			if result:
				var include_filename: String = result.get_string(1)
				var include_path: String = include_dir + include_filename
				var include_file := FileAccess.open(include_path, FileAccess.READ)

				if include_file:
					shader_code += include_file.get_as_text() + "\n"
				else:
					push_error("Failed to include file: " + include_path)
			else:
				push_error("Malformed #include directive: " + line)
		else:
			shader_code += line + "\n"

	return shader_code
