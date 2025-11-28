# quick_actions_plugin.gd
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
	
	# Register autoload if not already present
	if not ProjectSettings.has_setting("autoload/QuickActionsPanel"):
		ProjectSettings.set_setting("autoload/QuickActionsPanel", "res://addons/quick_actions/quick_actions_panel.tscn")
		ProjectSettings.save()
		print("Quick Actions autoload added.")

	# Load panel scene
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
		
	# Remove autoload when addon is disabled
	if ProjectSettings.has_setting("autoload/QuickActionsPanel"):
		ProjectSettings.set_setting("autoload/QuickActionsPanel", null)
		ProjectSettings.save()
		print("Quick Actions autoload removed.")


func _toggle_panel() -> void:
	if panel_instance:
		panel_instance.visible = !panel_instance.visible
