shader_type canvas_item;

// --- Uniforms --- //
void fragment() {
	COLOR.rgb = vec3((COLOR.r + COLOR.g + COLOR.b) / 5.0);
}