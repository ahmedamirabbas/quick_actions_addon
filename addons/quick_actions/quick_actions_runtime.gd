extends CanvasLayer

var panel_instance: Control

func _ready() -> void:
	# Set very high layer to render on top of everything
	layer = 4096
	
	# CRITICAL: Process mode to always run
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Load and add panel
	var panel_scene: PackedScene = preload("res://addons/quick_actions/quick_actions_panel.tscn")
	panel_instance = panel_scene.instantiate()
	
	# Ensure panel processes input
	panel_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(panel_instance)
	
	# Start visible
	panel_instance.show()
	
	print("Quick Actions Runtime loaded - Press Ctrl+Shift+Q to toggle")

func _input(event: InputEvent) -> void:
	# Toggle panel with Ctrl+Shift+Q
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q and event.ctrl_pressed and event.shift_pressed:
			if panel_instance:
				panel_instance.visible = !panel_instance.visible
			get_viewport().set_input_as_handled()
