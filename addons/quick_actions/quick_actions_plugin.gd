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
	
	# Register runtime autoload (only if not already present)
	if not ProjectSettings.has_setting("autoload/QuickActionsRuntime"):
		add_autoload_singleton("QuickActionsRuntime", "res://addons/quick_actions/quick_actions_runtime.gd")
	
	# Load panel scene for EDITOR ONLY
	var panel_scene: PackedScene = preload("res://addons/quick_actions/quick_actions_panel.tscn")
	panel_instance = panel_scene.instantiate()
	panel_instance.hide()
	
	# Add to editor interface
	get_editor_interface().get_base_control().add_child(panel_instance)
	
	print("Quick Actions Panel enabled (Editor only)")

func _exit_tree() -> void:
	# Clean up toolbar button
	if button:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
		button = null
	
	# Clean up editor panel instance
	if panel_instance:
		if panel_instance.get_parent():
			panel_instance.get_parent().remove_child(panel_instance)
		panel_instance.queue_free()
		panel_instance = null
	
	# Remove autoload
	if ProjectSettings.has_setting("autoload/QuickActionsRuntime"):
		remove_autoload_singleton("QuickActionsRuntime")
	
	print("Quick Actions Panel disabled")

func _toggle_panel() -> void:
	if panel_instance:
		panel_instance.visible = !panel_instance.visible
