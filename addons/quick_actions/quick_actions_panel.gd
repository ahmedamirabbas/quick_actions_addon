@tool
extends PanelContainer

@onready var screenshot_btn: Button = %ScreenshotButton
@onready var reload_btn: Button = %ReloadButton
@onready var fps_btn: Button = %FPSButton
@onready var timescale_slider: HSlider = %TimescaleSlider
@onready var timescale_label: Label = %TimescaleLabel

var fps_counter: Control
var is_fps_visible: bool = false

func _ready() -> void:
	# Connect buttons
	screenshot_btn.pressed.connect(_on_screenshot_pressed)
	reload_btn.pressed.connect(_on_reload_pressed)
	fps_btn.pressed.connect(_on_fps_toggle_pressed)
	timescale_slider.value_changed.connect(_on_timescale_changed)
	
	# Setup dragging
	gui_input.connect(_on_panel_input)
	
	# Initialize timescale
	_on_timescale_changed(timescale_slider.value)

var dragging: bool = false
var drag_offset: Vector2

func _on_panel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_screenshot_pressed() -> void:
	var editor_interface: EditorInterface = Engine.get_singleton("EditorInterface") if Engine.has_singleton("EditorInterface") else null
	if not editor_interface:
		return
	
	var viewport: Viewport = editor_interface.get_editor_viewport_3d(0) if editor_interface.get_editor_viewport_3d(0) else get_viewport()
	var image: Image = viewport.get_texture().get_image()
	
	var timestamp: String = Time.get_datetime_string_from_system().replace(":", "-")
	var path: String = "user://screenshot_%s.png" % timestamp
	
	image.save_png(path)
	print("Screenshot saved to: %s" % ProjectSettings.globalize_path(path))

func _on_reload_pressed() -> void:
	if Engine.is_editor_hint():
		print("Reload Scene works only in running game")
		return
	
	get_tree().reload_current_scene()

func _on_fps_toggle_pressed() -> void:
	is_fps_visible = !is_fps_visible
	
	if is_fps_visible:
		if not fps_counter:
			fps_counter = preload("res://addons/quick_actions/tools/fps_counter.tscn").instantiate()
			get_tree().root.add_child(fps_counter)
		fps_counter.show()
		fps_btn.text = "Hide FPS"
	else:
		if fps_counter:
			fps_counter.hide()
		fps_btn.text = "Show FPS"

func _on_timescale_changed(value: float) -> void:
	Engine.time_scale = value
	timescale_label.text = "Speed: %.2fx" % value
