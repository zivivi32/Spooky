extends Node

# Enum for graphics quality levels
enum GraphicsQuality {
	LOW,
	MEDIUM,
	HIGH
}

# Graphics configuration class
class GraphicsConfig:
	var fog_enabled: bool = true
	var fog_density: float = 1.0
	var global_illumination_quality: float = 1.0
	var shadow_quality: float = 1.0
	var shader_complexity: float = 1.0

# Current graphics configuration
var current_graphics_config: GraphicsConfig
var current_quality_level: int = GraphicsQuality.HIGH

# Performance thresholds
const MEMORY_LOW_THRESHOLD: int = 1024  # MB
const MEMORY_MEDIUM_THRESHOLD: int = 4096  # MB

# Performance monitoring variables
var initial_performance_check_done: bool = false

func _ready():
	# Defer initial performance check to ensure all systems are loaded
	call_deferred("perform_initial_performance_check")

func perform_initial_performance_check():
	# Automatically detect and set graphics quality
	detect_and_set_graphics_quality()
	initial_performance_check_done = true

func detect_and_set_graphics_quality():
	var memory = get_video_memory()
	var cpu_cores = OS.get_processor_count()
	var graphics_adapter = RenderingServer.get_rendering_device().get_device_name().to_lower()
	
	print("Detected System Specs:")
	print("Video Memory: ", memory, " MB")
	print("CPU Cores: ", cpu_cores)
	print("Graphics Adapter: ", graphics_adapter)
	
	# Comprehensive quality detection
	if memory < MEMORY_LOW_THRESHOLD or "intel" in graphics_adapter:
		set_graphics_quality(GraphicsQuality.LOW)
	elif memory < MEMORY_MEDIUM_THRESHOLD or cpu_cores < 4:
		set_graphics_quality(GraphicsQuality.MEDIUM)
	else:
		set_graphics_quality(GraphicsQuality.HIGH)

func get_video_memory() -> int:
	# In Godot 4, we can try to get an estimate of available video memory
	# This is a simplified approach
	var total_memory = OS.get_memory_info()
	if total_memory and total_memory.get("total_physical_memory"):
		return total_memory["total_physical_memory"] / (1024 * 1024)  # Convert to MB
	return 512  # Fallback value if we can't get the memory info

func set_graphics_quality(quality_level: int):
	current_quality_level = quality_level
	current_graphics_config = create_graphics_config(quality_level)
	apply_graphics_configuration(current_graphics_config)
	
	print("Graphics Quality Set To: ", get_quality_name(quality_level))

func create_graphics_config(quality_level: int) -> GraphicsConfig:
	var config = GraphicsConfig.new()
	
	match quality_level:
		GraphicsQuality.LOW:
			config.fog_enabled = false
			config.fog_density = 0.1
			config.global_illumination_quality = 0.2
			config.shadow_quality = 0.1
			config.shader_complexity = 0.2
		
		GraphicsQuality.MEDIUM:
			config.fog_enabled = true
			config.fog_density = 0.5
			config.global_illumination_quality = 0.5
			config.shadow_quality = 0.5
			config.shader_complexity = 0.5
		
		GraphicsQuality.HIGH:
			config.fog_enabled = true
			config.fog_density = 1.0
			config.global_illumination_quality = 1.0
			config.shadow_quality = 1.0
			config.shader_complexity = 1.0
	
	return config

func apply_graphics_configuration(config: GraphicsConfig):
	# Apply fog settings
	apply_fog_settings(config)
	
	# Apply global illumination
	apply_global_illumination(config)
	
	# Apply shadow settings
	apply_shadow_settings(config)
	
	# Additional custom rendering optimizations
	optimize_rendering(config)

func apply_fog_settings(config: GraphicsConfig):
	# Find your WorldEnvironment node or Environment resource
	if get_tree().get_root().has_node("WorldEnvironment"):
		var world_env = get_tree().get_root().get_node("WorldEnvironment")
		if world_env.environment:
			world_env.environment.fog_enabled = config.fog_enabled
			world_env.environment.fog_density = config.fog_density

func apply_global_illumination(config: GraphicsConfig):
	if get_tree().get_root().has_node("WorldEnvironment"):
		var world_env = get_tree().get_root().get_node("WorldEnvironment")
		if world_env.environment:
			# Adjust GI-related settings
			world_env.environment.glow_intensity = config.global_illumination_quality
			world_env.environment.ssao_enabled = config.global_illumination_quality > 0.5
			world_env.environment.ssil_enabled = config.global_illumination_quality > 0.8

func apply_shadow_settings(config: GraphicsConfig):
	# Adjust shadow quality based on configuration
	var shadow_size = int(lerp(1024, 4096, config.shadow_quality))
	get_viewport().positional_shadow_atlas_size = shadow_size
	
	# Adjust shadow filtering quality
	RenderingServer.directional_soft_shadow_filter_set_quality(
		1 if config.shadow_quality < 0.3 else
		2 if config.shadow_quality < 0.7 else
		3
	)

func optimize_rendering(config: GraphicsConfig):
	var viewport = get_viewport()
	
	# Adjust MSAA based on quality
	viewport.msaa_3d = (
		Viewport.MSAA_DISABLED if config.shader_complexity < 0.3
		else Viewport.MSAA_2X if config.shader_complexity < 0.7
		else Viewport.MSAA_4X
	)
	
	# Screen-space reflections quality
	if get_tree().get_root().has_node("WorldEnvironment"):
		var world_env = get_tree().get_root().get_node("WorldEnvironment")
		if world_env.environment:
			world_env.environment.ssr_enabled = config.shader_complexity > 0.5
			world_env.environment.ssao_enabled = config.shader_complexity > 0.3

func get_quality_name(quality_level: int) -> String:
	match quality_level:
		GraphicsQuality.LOW:
			return "Low Quality"
		GraphicsQuality.MEDIUM:
			return "Medium Quality"
		GraphicsQuality.HIGH:
			return "High Quality"
	return "Unknown Quality"

# Optional: Manual quality override
func manually_set_quality(quality_level: int):
	if quality_level in GraphicsQuality.values():
		set_graphics_quality(quality_level)
	else:
		print("Invalid quality level")

# Optional: Add a runtime quality adjustment method
func adjust_quality_runtime():
	var fps = Engine.get_frames_per_second()
	if fps < 30 and current_quality_level > GraphicsQuality.LOW:
		set_graphics_quality(current_quality_level - 1)
		print("Automatically reducing quality due to low FPS: ", fps)
