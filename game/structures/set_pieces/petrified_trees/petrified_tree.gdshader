shader_type canvas_item;
// MUNN: THIS IS SO SCUFFED IT'S JUST HOW I'M CHECKING IF A SPRITE HAS THIS SPECIFIC SHADER
uniform bool shader_is_petrified = true;

uniform float alpha = 1.0;
uniform bool is_flashing = false;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = 0.299 * tex_color.r + 0.587 * tex_color.g + 0.114 * tex_color.b;

	if (is_flashing) {
		COLOR = vec4(1.0, 1.0, 1.0, tex_color.a * alpha);
	} else {
		COLOR = vec4(vertex_color.r * gray, vertex_color.g * gray, vertex_color.b * gray, tex_color.a * alpha);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
