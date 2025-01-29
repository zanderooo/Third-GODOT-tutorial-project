extends Node

const PAUSE_MENU = preload("res://UI/pause_menu.tscn")
const LEVEL_1 = preload("res://scenes/level1.tscn")
const MAIN_MENU = preload("res://UI/main_menu.tscn")

func _ready():
	RenderingServer.set_default_clear_color(Color(0.44,0.12,0.53,1.00))
	SettingsManager.load_settings()
	
func start_game():
	
	if get_tree().paused:
		continue_game()
		return
	transition_to_scene(LEVEL_1.resource_path)

func exit_game():
	get_tree().quit()
	
func transition_to_scene(scene_path):
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)

func continue_game():
	get_tree().paused = false
	

func main_menu():
	var main_menu_screen_instance = MAIN_MENU.instantiate()
	get_tree().get_root().add_child(main_menu_screen_instance)
func pause_game():
	get_tree().paused = true
	
	var pause_menu_screen_instance = PAUSE_MENU.instantiate()
	get_tree().get_root().add_child(pause_menu_screen_instance)
