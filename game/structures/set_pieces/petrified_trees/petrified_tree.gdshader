shader_type canvas_item;

uniform float alpha = 1.0;
uniform bool is_flashing = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = 0.299 * tex_color.r + 0.587 * tex_color.g + 0.114 * tex_color.b;
	
	if (is_flashing) {
		COLOR = vec4(1.0, 1.0, 1.0, tex_color.a * alpha);
	} else {
		COLOR = vec4(gray, gray, gray, tex_color.a * alpha);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
