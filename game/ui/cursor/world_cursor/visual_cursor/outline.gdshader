shader_type canvas_item;

uniform int outline_width = 1;
uniform float outline_alpha = 1.0;
uniform vec3 outline_color: source_color = vec3(1.0, 1.0, 1.0);

bool is_on_edge(vec2 uv, sampler2D texture2d, vec2 texture_pixel_size) {
	vec4 color = texture(texture2d, uv);

	if (color.a > 0.0) {
		return false;
	}

	for (int x = -outline_width; x <= outline_width; x++) {
		for (int y = -outline_width; y <= outline_width; y++) {
			if (abs(float(x)) + abs(float(y)) > float(outline_width)) {
				continue;
			}

			vec4 surrounding_color = texture(texture2d, uv + vec2(float(x) * texture_pixel_size.x, float(y) * texture_pixel_size.y));
			if (surrounding_color.a > 0.0) {
				return true;
			}
		}
	}
	return false;
}

void fragment() {
	if (is_on_edge(UV, TEXTURE, TEXTURE_PIXEL_SIZE)) {
		COLOR = vec4(outline_color, outline_alpha);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
