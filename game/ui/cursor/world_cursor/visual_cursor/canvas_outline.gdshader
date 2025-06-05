shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform bool match_camera_zoom = true;
uniform vec2 camera_zoom = vec2(1.0, 1.0);

uniform int outline_width = 1;
uniform float outline_alpha: hint_range(0.0, 1.0) = 1.0;
uniform vec3 outline_color: source_color = vec3(1.0, 1.0, 1.0);

bool is_on_edge(vec2 uv, sampler2D texture2d, vec2 texture_pixel_size) {
	vec4 color = texture(texture2d, uv);

	if (color.a > 0.0) {
		return false;
	}
	
	vec2 size = texture_pixel_size;
	if (match_camera_zoom) {
		size = vec2(size.x * camera_zoom.x, size.y * camera_zoom.y);
	}

	for (int x = -outline_width; x <= outline_width; x++) {
		for (int y = -outline_width; y <= outline_width; y++) {
			if (abs(float(x)) + abs(float(y)) > float(outline_width)) {
				continue;
			}
			
			vec4 surrounding_color = texture(texture2d, uv + vec2(float(x) * size.x, float(y) * size.y));
			if (surrounding_color.a > 0.0) {
				return true;
			}
		}
	}
	return false;
}

void fragment() {
	if (is_on_edge(SCREEN_UV, screen_texture, SCREEN_PIXEL_SIZE)) {
		COLOR = vec4(outline_color, outline_alpha);
	} else if (texture(screen_texture, SCREEN_UV).a == 0.0) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
