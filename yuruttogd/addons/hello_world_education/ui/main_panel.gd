@tool
extends Control

func _ready() -> void:
	print("Education Main Panel ready!")


func _on_start_button_pressed() -> void:
	print("Start Learning button pressed!")
	# Future: Load first lesson


func _on_settings_button_pressed() -> void:
	print("Settings button pressed!")
	# Future: Show settings dialog


func _on_exit_button_pressed() -> void:
	print("Exit button pressed!")
	# Close the application
	get_tree().quit()
