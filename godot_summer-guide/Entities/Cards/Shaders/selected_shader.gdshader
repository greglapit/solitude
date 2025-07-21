shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 shine_color = vec4(1.0, 1.0, 1.0, .2);
uniform float shine_speed : hint_range(0.0, 10.0, 0.1) = 50.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = .9;

void fragment() {

	// Shine Effect
	vec4 target_red = vec4(0.702, 0.22, 0.192, 1.0);
	if (COLOR.r > 0.7 && COLOR.g < 0.3) {
		COLOR = texture(TEXTURE,UV);
		float shine = step(1.0 - shine_size * 0.5, 0.5 + 0.5 * sin(UV.x + UV.y + TIME * shine_speed * 5.0));
		COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
	}

	// Highlight Effect
	if (COLOR.r > 0.7 && COLOR.b > 0.7 && COLOR.b > 0.7) {
		COLOR = COLOR + vec4(.15);
	}

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
