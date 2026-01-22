shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float force;
uniform float size;
uniform float thickness;
uniform vec2 center = vec2(.5,.5);

void vertex() {
}

void fragment() {
	float mask = (1.0 - smoothstep(size - .1, size, length(UV - center))) * smoothstep(size - thickness - 0.1,size-thickness, length(UV - center));;

	vec2 disp = (UV - vec2(.5,.5)) * force * mask;
	COLOR = texture(screen_texture, SCREEN_UV - disp);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
