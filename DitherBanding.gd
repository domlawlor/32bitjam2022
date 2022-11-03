extends ViewportContainer

func _ready():
	material.set_shader_param("canvasResolution", rect_size)
