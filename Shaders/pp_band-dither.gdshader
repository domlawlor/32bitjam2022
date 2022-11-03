shader_type canvas_item;
// originally based on https://github.com/WittyCognomen/godot-psx-shaders-demo/blob/master/shaders/psx_dither_post.shader

uniform sampler2D dither_tex: hint_white;
uniform float col_depth = 15.0;
uniform bool dither_banding = true;
uniform bool enable_col_depth = true;

void fragment() {
	vec2 gameRes = vec2(320, 240);
	vec2 ditherRes = vec2(4, 4);

	COLOR = texture(TEXTURE, UV);

	vec2 ditherUV = UV * (gameRes / ditherRes);
	
	vec3 ditherFrag = texture(dither_tex, ditherUV).rgb;
	ditherFrag -= 0.5;
	ditherFrag *= (dither_banding ? 1.0 : 0.0);
	
	if(enable_col_depth)
	{
		COLOR.rgb = round(COLOR.rgb * col_depth + ditherFrag) / col_depth;
	}
	else
	{
		COLOR.rgb = mix(COLOR.rgb, ditherFrag, 0.05)
	}
	
	
}

