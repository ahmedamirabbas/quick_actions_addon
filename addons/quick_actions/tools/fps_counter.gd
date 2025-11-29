extends Control

@onready var fps_label: Label = $Label

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	offset_left = -150
	offset_right = -10
	offset_top = 10
	offset_bottom = 60

func _process(_delta: float) -> void:
	if not fps_label:
		return
	
	var fps: int = Engine.get_frames_per_second()
	var color: Color = Color.GREEN if fps >= 60 else Color.YELLOW if fps >= 30 else Color.RED
	
	fps_label.text = "FPS: %d" % fps
	fps_label.add_theme_color_override("font_color", color)
