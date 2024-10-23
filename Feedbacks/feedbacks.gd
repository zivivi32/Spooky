extends Node
class_name visual_feedbacks

@export_subgroup("Chromatic Aberration")
@export var chromatic_aberration : CanvasLayer
@export var chromatic_aberration_duration : float = 1.0
@export var chromatic_aberration_rect : ColorRect
@export var aberration_value : float = 10

@export_subgroup("Blur")
@export var blur : CanvasLayer
@export var blur_duration : float = 1.0
@export var blur_rect : ColorRect
@export var blur_value : float = 1

@export_subgroup("Fish eye")
@export var fish_eye : CanvasLayer
@export var fish_eye_duration : float = 1.0
@export var fish_eye_intensity : float = 10
@export var fish_eye_rect : ColorRect

@export_subgroup("Glitch")
@export var glitch : CanvasLayer
@export var glitch_rect: ColorRect
@export var glitch_intensity: float = 0.05
@export var glitch_duration: float = 1.0

@export_subgroup("CRT")
@export var crt : CanvasLayer
@export var crt_rect: ColorRect
@export var crt_intensity: float = 0.05
@export var crt_duration: float = 1.0

@export_subgroup("Speed lines")
@export var speed_lines : CanvasLayer
@export var speed_lines_duration: float = 1.0

@export_subgroup("Screen shake")
@export var screen_shake : CanvasLayer
@export var screen_shake_rect: ColorRect
@export var screen_shake_timer: Timer
@export var screen_shake_duration: float = 1.0
@export var screen_shake_intensity: float = 0.5

@export_subgroup("Screen shake Toggle")
@export var screen_shake_toggle : CanvasLayer
@export var screen_shake_rect_toggle: ColorRect
@export var screen_shake_intensity_toggle: float = 0.5


@export_subgroup("Vignette")
@export var vignette : CanvasLayer
@export var vignette_duration : float = 1.0

@export_subgroup("Pixelate")
@export var pixelate : CanvasLayer
@export var pixelate_rect: ColorRect
@export var pixelate_factor: int = 4
@export var pixelate_duration : float = 1.0
@export var pixelate_timer: Timer

@export var fx_timer : Timer

var fx_duration : float = 1
var fx_value : float

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("fx_chromatic_aberration", chromatic_aberration_signal)
	Events.connect("fx_blur", blur_signal)
	Events.connect("fx_screen_shake", screen_shake_signal)
	Events.connect("fx_screen_shake_toggle", screen_shake_toggle_signal)
	Events.connect("fx_pixelate", pixelate_signal)
	Events.connect("fx_glitch", glitch_signal)
	Events.connect("fx_crt", crt_signal)
	Events.connect("fx_fish_eye", fish_eye_signal)
	
	pixelate_timer.connect("timeout", _on_pixelate_timer_timeout)
	screen_shake_timer.connect("timeout", _on_screen_shake_timeout)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if chromatic_aberration != null:
		if chromatic_aberration.visible:
			aberration_value = lerpf(aberration_value, 0, chromatic_aberration_duration)
			chromatic_aberration_feedback(aberration_value)
			
	if blur != null:
		if blur.visible:
			blur_value = lerpf(blur_value, 0, blur_duration)
			blur_feedback(blur_value)			
			
	if fish_eye!=null:
		if fish_eye.visible:
			fish_eye_intensity = lerpf(fish_eye_intensity, 0, fish_eye_duration)
			fish_eye_feedback(fish_eye_intensity)
			
			
###### Signal functions
func chromatic_aberration_signal(duration : float = 0.05, intensity : float = 10):
	aberration_value = intensity
	chromatic_aberration_rect.material.set("shader_parameter/offset", intensity)
	chromatic_aberration_duration = duration
	chromatic_aberration.visible = true

func blur_signal(duration : float = 0.05, intensity : float = 1.5):
	blur_value = intensity
	blur_duration = duration
	blur.visible = true


func fish_eye_signal(duration: float = 0.05, intensity: float = 1.5):
	fish_eye_duration = duration
	fish_eye_intensity = intensity
	fish_eye.visible = true
	
func pixelate_signal(duration: float = 0.1, intensity: int = 4):
	pixelate_rect.material.set("shader_parameter/pixelSize", intensity)
	pixelate_timer.wait_time = duration
	pixelate.visible = true
	pixelate_timer.start()

func screen_shake_signal(duration: float = 0.1, _intensity : float = 0.2):
	screen_shake_intensity = _intensity
	screen_shake_rect.material.set("shader_parameter/ShakeStrength", _intensity)
	screen_shake_timer.wait_time = duration
	screen_shake.visible = true
	screen_shake_timer.start()

func screen_shake_toggle_signal(_intensity : float = 0.2, _visible: bool = false):
	screen_shake_intensity = _intensity
	screen_shake_rect.material.set("shader_parameter/ShakeStrength", _intensity)
	screen_shake.visible = _visible

func glitch_signal():
	glitch.visible = !glitch.visible

func crt_signal():
	crt.visible = !crt.visible
	
	
################## Feedback functions ################
func chromatic_aberration_feedback(value : float):
	chromatic_aberration_rect.material.set("shader_parameter/offset", value)
	if value <= 0:
		chromatic_aberration.visible = false

func blur_feedback(value : float):
	blur_rect.material.set("shader_parameter/lod", value)
	if value < 0.1:
		blur.visible = false

func fish_eye_feedback(value: float):
	fish_eye_rect.material.set("shader_parameter/effect_amount", value)
	if value <= 0.1:
		fish_eye.visible = false

func pixelate_feedback():
		pixelate.visible = false

func screenshake_feedback():
	screen_shake.visible = false
		
func glitch_feedback(value: float = 0.05):
	var _intensity = value
	pass
	
func speedlines_feedback():
	pass

func vignette_feedback():
	pass

func _on_screen_shake_timeout():
	screenshake_feedback()
	#pass # Replace with function body.
func _on_pixelate_timer_timeout():
	pixelate_feedback()
