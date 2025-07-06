class_name DataUtil

## DATA UTILITY
## Common methods for loading data into the game

## TODO: Async loading methodology

## RECURSIVELY loads all Resources of type resource_type in path and returns the list
## NOTE: This method is synchronous
static func load_all_resources_in_folder(path: String, resource_type: String, log_loading: bool = true, level: int = 1) -> Array[Resource]:
	var result: Array[Resource] = []
	
	if log_loading:
		print(".".repeat(level) + " Loading resources of type {type} from {path}...".format({ "type": resource_type, "path": path }))
	
	## FIX
	## - Allows the engine to use editor paths at build runtime
	## NOTE: Builds will only load resources correctly if ProjectSettings/Editor/Export convert_text_resources_to_binary is set to FALSE 
	var file_names: PackedStringArray = ResourceLoader.list_directory(path + "/")
	
	for file_name: String in file_names:
		var file_path = path + file_name
		
		if file_name.ends_with("/"): ## Is a directory
			result.append_array(load_all_resources_in_folder(file_path, resource_type, log_loading, level + 1))
		else:
			if log_loading:
				print(".".repeat(level + 1) + " Loading {file_name} ({path})...".format({ "file_name": file_name, "path": file_path }))
			
			var resource: Resource = ResourceLoader.load(file_path, resource_type)
			if resource:
				result.append(resource)
	
	return result

## RECURSIVELY loads all PackedScenes in path and returns the list
## NOTE: This method is synchronous
static func load_all_scenes_in_folder(path: String, log_loading: bool = true, level: int = 1) -> Array[PackedScene]:
	var result: Array[PackedScene] = []
	
	if log_loading:
		print(".".repeat(level) + " Loading scenes of from {path}...".format({ "path": path }))
	
	## FIX
	## - Allows the engine to use editor paths at build runtime
	## NOTE: Builds will only load resources correctly if ProjectSettings/Editor/Export convert_text_resources_to_binary is set to FALSE 
	var file_names: PackedStringArray = ResourceLoader.list_directory(path + "/")
	
	for file_name: String in file_names:
		var file_path = path + file_name
		
		if file_name.ends_with("/"): ## Is a directory
			result.append_array(load_all_scenes_in_folder(file_path, log_loading, level + 1))
		else:
			if log_loading:
				print(".".repeat(level + 1) + " Loading {file_name} ({path})...".format({ "file_name": file_name, "path": file_path }))
			
			var scene: PackedScene = load(file_path)
			if scene:
				result.append(scene)
	
	return result
