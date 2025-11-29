@tool
extends PanelContainer

@onready var screenshot_btn: Button = %ScreenshotButton
@onready var reload_btn: Button = %ReloadButton
@onready var fps_btn: Button = %FPSButton
@onready var timescale_slider: HSlider = %TimescaleSlider
@onready var timescale_label: Label = %TimescaleLabel
@onready var minimize_btn: Button = %MinimizeButton
@onready var content_container: VBoxContainer = %ContentContainer

var fps_counter: Control
var is_fps_visible: bool = false

# Dragging variables
var dragging: bool = false
var drag_offset: Vector2

# Resizing variables
var resizing: bool = false
var resize_start_pos: Vector2
var resize_start_size: Vector2
const RESIZE_MARGIN: float = 10.0
const MIN_SIZE: Vector2 = Vector2(200, 250)
const MAX_SIZE: Vector2 = Vector2(400, 600)

# Minimize variables
var is_minimized: bool = false
var expanded_size: Vector2
const MINIMIZED_HEIGHT: float = 50.0

const HOTKEY_SCREENSHOT: String = "quick_action_screenshot"
const HOTKEY_RELOAD: String = "quick_action_reload"
const HOTKEY_FPS: String = "quick_action_fps"
const HOTKEY_TIMESCALE_UP: String = "quick_action_speed_up"
const HOTKEY_TIMESCALE_DOWN: String = "quick_action_speed_down"
const HOTKEY_TIMESCALE_RESET: String = "quick_action_speed_reset"

func _ready() -> void:
	# CRITICAL: Ensure mouse interaction works in CanvasLayer
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make sure we're processing input
	set_process_input(true)
	
	# Set initial size (but allow resizing)
	custom_minimum_size = MIN_SIZE
	size = Vector2(240, 280)
	expanded_size = size
	
	# Enable mouse filter
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect buttons
	screenshot_btn.pressed.connect(_on_screenshot_pressed)
	reload_btn.pressed.connect(_on_reload_pressed)
	fps_btn.pressed.connect(_on_fps_toggle_pressed)
	timescale_slider.value_changed.connect(_on_timescale_changed)
	minimize_btn.pressed.connect(_on_minimize_pressed)
	
	# Setup input handling
	gui_input.connect(_on_panel_input)
	
	# Register hotkeys (only works during runtime)
	_register_hotkeys()
	
	# Initialize timescale
	_on_timescale_changed(timescale_slider.value)
	
	# Position panel
	call_deferred("_position_panel")

func _position_panel() -> void:
	if is_inside_tree():
		var viewport_size := get_viewport().get_visible_rect().size
		position = Vector2(
			viewport_size.x - size.x - 20,
			viewport_size.y - size.y - 20
		)

func _on_minimize_pressed() -> void:
	is_minimized = !is_minimized
	
	if is_minimized:
		# Save current size and minimize
		expanded_size = size
		content_container.hide()
		minimize_btn.text = "+"
		custom_minimum_size = Vector2(size.x, MINIMIZED_HEIGHT)
		size = Vector2(size.x, MINIMIZED_HEIGHT)
	else:
		# Restore to expanded size
		content_container.show()
		minimize_btn.text = "−"
		custom_minimum_size = MIN_SIZE
		size = expanded_size

func _register_hotkeys() -> void:
	if not InputMap.has_action(HOTKEY_SCREENSHOT):
		InputMap.add_action(HOTKEY_SCREENSHOT)
		var screenshot_key := InputEventKey.new()
		screenshot_key.keycode = KEY_F9
		InputMap.action_add_event(HOTKEY_SCREENSHOT, screenshot_key)
	
	if not InputMap.has_action(HOTKEY_RELOAD):
		InputMap.add_action(HOTKEY_RELOAD)
		var reload_key := InputEventKey.new()
		reload_key.keycode = KEY_R
		reload_key.ctrl_pressed = true
		InputMap.action_add_event(HOTKEY_RELOAD, reload_key)
	
	if not InputMap.has_action(HOTKEY_FPS):
		InputMap.add_action(HOTKEY_FPS)
		var fps_key := InputEventKey.new()
		fps_key.keycode = KEY_F3
		InputMap.action_add_event(HOTKEY_FPS, fps_key)
	
	if not InputMap.has_action(HOTKEY_TIMESCALE_UP):
		InputMap.add_action(HOTKEY_TIMESCALE_UP)
		var speed_up_key := InputEventKey.new()
		speed_up_key.keycode = KEY_EQUAL
		speed_up_key.ctrl_pressed = true
		InputMap.action_add_event(HOTKEY_TIMESCALE_UP, speed_up_key)
	
	if not InputMap.has_action(HOTKEY_TIMESCALE_DOWN):
		InputMap.add_action(HOTKEY_TIMESCALE_DOWN)
		var speed_down_key := InputEventKey.new()
		speed_down_key.keycode = KEY_MINUS
		speed_down_key.ctrl_pressed = true
		InputMap.action_add_event(HOTKEY_TIMESCALE_DOWN, speed_down_key)
	
	if not InputMap.has_action(HOTKEY_TIMESCALE_RESET):
		InputMap.add_action(HOTKEY_TIMESCALE_RESET)
		var speed_reset_key := InputEventKey.new()
		speed_reset_key.keycode = KEY_0
		speed_reset_key.ctrl_pressed = true
		InputMap.action_add_event(HOTKEY_TIMESCALE_RESET, speed_reset_key)

func _input(event: InputEvent) -> void:
	# Only process during runtime
	if Engine.is_editor_hint():
		return
	
	# Must be in tree and visible
	if not is_inside_tree() or not visible:
		return
	
	# Safe viewport access
	var viewport := get_viewport()
	if viewport == null:
		return
	
	if event.is_action_pressed(HOTKEY_SCREENSHOT):
		_on_screenshot_pressed()
		viewport.set_input_as_handled()
	
	elif event.is_action_pressed(HOTKEY_RELOAD):
		_on_reload_pressed()
		viewport.set_input_as_handled()
	
	elif event.is_action_pressed(HOTKEY_FPS):
		_on_fps_toggle_pressed()
		viewport.set_input_as_handled()
	
	elif event.is_action_pressed(HOTKEY_TIMESCALE_UP):
		timescale_slider.value = min(timescale_slider.value + 0.25, timescale_slider.max_value)
		viewport.set_input_as_handled()
	
	elif event.is_action_pressed(HOTKEY_TIMESCALE_DOWN):
		timescale_slider.value = max(timescale_slider.value - 0.25, timescale_slider.min_value)
		viewport.set_input_as_handled()
	
	elif event.is_action_pressed(HOTKEY_TIMESCALE_RESET):
		timescale_slider.value = 1.0
		viewport.set_input_as_handled()

func _is_in_resize_zone(mouse_pos: Vector2) -> bool:
	# Don't allow resizing when minimized
	if is_minimized:
		return false
	
	var local_pos := mouse_pos - global_position
	var panel_size := size
	
	# Check if near bottom-right corner
	return (local_pos.x >= panel_size.x - RESIZE_MARGIN and 
			local_pos.y >= panel_size.y - RESIZE_MARGIN)

func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos := get_global_mouse_position()
				
				# Check if clicking in resize zone
				if _is_in_resize_zone(mouse_pos):
					resizing = true
					resize_start_pos = mouse_pos
					resize_start_size = size
				else:
					# Start dragging
					dragging = true
					drag_offset = mouse_pos - global_position
			else:
				# Stop both dragging and resizing
				dragging = false
				resizing = false
	
	elif event is InputEventMouseMotion:
		if resizing:
			# Handle resize
			var mouse_pos := get_global_mouse_position()
			var delta := mouse_pos - resize_start_pos
			var new_size := resize_start_size + delta
			
			# Clamp to min/max size
			new_size.x = clamp(new_size.x, MIN_SIZE.x, MAX_SIZE.x)
			new_size.y = clamp(new_size.y, MIN_SIZE.y, MAX_SIZE.y)
			
			size = new_size
			custom_minimum_size = new_size
			expanded_size = new_size  # Update expanded size while resizing
			
		elif dragging:
			# Handle drag
			var mouse_pos := get_global_mouse_position()
			global_position = mouse_pos - drag_offset
		else:
			# Update cursor based on position
			if _is_in_resize_zone(get_global_mouse_position()):
				mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
			else:
				mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_screenshot_pressed() -> void:
	if Engine.is_editor_hint():
		print("⚠ Screenshot works only during runtime (press Play button first)")
		return
	
	# Find and hide CanvasLayer
	var canvas_layer: CanvasLayer = null
	if get_parent() is CanvasLayer:
		canvas_layer = get_parent()
		canvas_layer.visible = false
	
	# Hide FPS counter if visible
	var fps_was_visible: bool = false
	if fps_counter and fps_counter.visible:
		fps_was_visible = true
		fps_counter.hide()
	
	# Wait for render to update
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Capture screenshot
	var viewport: Viewport = get_tree().root
	var image: Image = viewport.get_texture().get_image()
	
	var timestamp: String = Time.get_datetime_string_from_system().replace(":", "-")
	var path: String = "user://screenshot_%s.png" % timestamp
	
	var error := image.save_png(path)
	
	if error == OK:
		print("✓ Screenshot saved: %s" % ProjectSettings.globalize_path(path))
	else:
		print("✗ Screenshot failed with error code: %d" % error)
	
	# Restore visibility
	if canvas_layer:
		canvas_layer.visible = true
	
	if fps_was_visible:
		fps_counter.show()

func _on_reload_pressed() -> void:
	if Engine.is_editor_hint():
		print("⚠ Reload works only during runtime (press Play button first)")
		return
		
	if fps_counter:
		fps_counter.queue_free()
	
	get_tree().reload_current_scene()

func _on_fps_toggle_pressed() -> void:
	if Engine.is_editor_hint():
		print("⚠ Show FPS works only during runtime (press Play button first)")
		return
		
	is_fps_visible = !is_fps_visible
	
	if is_fps_visible:
		if not fps_counter:
			fps_counter = preload("res://addons/quick_actions/tools/fps_counter.tscn").instantiate()
			get_tree().root.add_child(fps_counter)
		fps_counter.show()
		fps_btn.text = "Hide FPS (F3)"
	else:
		if fps_counter:
			fps_counter.hide()
		fps_btn.text = "Show FPS (F3)"

func _on_timescale_changed(value: float) -> void:
	Engine.time_scale = value
	timescale_label.text = "Speed: %.2fx" % value
