shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float force;
uniform float size;
uniform float thickness;

void fragment() {
	vec2 center = vec2(.5,.5);
	float mask = (1.0 - smoothstep(size -0.1,size, length(UV - center))) * smoothstep(size - thickness - 0.1,size-thickness, length(UV - center));
	vec2 disp = normalize(UV - center) * force * mask;
	
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
	//COLOR = vec4(mask);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
