@tool
extends EditorPlugin

var main_panel: Control
var main_panel_instance: Control

func _enter_tree() -> void:
	# Load the main panel scene
	main_panel = preload("res://addons/hello_world_education/ui/main_panel.tscn").instantiate()

	# Add to editor main screen
	EditorInterface.get_editor_main_screen().add_child(main_panel)

	# Initially hidden (will be shown when user clicks the tab)
	_make_visible(false)

	print("Hello World Education Plugin loaded!")


func _exit_tree() -> void:
	if main_panel:
		main_panel.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel:
		main_panel.visible = visible


func _get_plugin_name() -> String:
	return "Education"


func _get_plugin_icon() -> Texture2D:
	# Return a built-in icon for now
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
