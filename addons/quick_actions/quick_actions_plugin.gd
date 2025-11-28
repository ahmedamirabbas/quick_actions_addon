@tool
extends EditorPlugin

var panel_instance: Control
var button: Button

func _enter_tree() -> void:
	# Create toolbar button
	button = Button.new()
	button.text = "⚡ Quick Actions"
	button.pressed.connect(_toggle_panel)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	
	# Register runtime autoload
	add_autoload_singleton("QuickActionsRuntime", "res://addons/quick_actions/quick_actions_runtime.gd")
	
	# Load panel scene for EDITOR ONLY
	var panel_scene: PackedScene = preload("res://addons/quick_actions/quick_actions_panel.tscn")
	panel_instance = panel_scene.instantiate()
	panel_instance.hide()
	
	# Add to editor interface
	get_editor_interface().get_base_control().add_child(panel_instance)

func _exit_tree() -> void:
	if button:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
	
	if panel_instance:
		panel_instance.queue_free()
	
	# Remove autoload
	remove_autoload_singleton("QuickActionsRuntime")

func _toggle_panel() -> void:
	if panel_instance:
		panel_instance.visible = !panel_instance.visible
