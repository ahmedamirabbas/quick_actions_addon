extends CanvasLayer

var panel_instance: Control

func _ready() -> void:
	# Set high layer to render on top
	layer = 4096
	
	# Load and add panel
	var panel_scene: PackedScene = preload("res://addons/quick_actions/quick_actions_panel.tscn")
	panel_instance = panel_scene.instantiate()
	add_child(panel_instance)
	
	# Start visible (you can change this)
	panel_instance.show()

func _input(event: InputEvent) -> void:
	# Toggle panel with a hotkey (Ctrl+Shift+Q)
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q and event.ctrl_pressed and event.shift_pressed:
			if panel_instance:
				panel_instance.visible = !panel_instance.visible
			get_viewport().set_input_as_handled()
