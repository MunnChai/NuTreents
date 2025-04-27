shader_type canvas_item;

// ---
// TREE DAMAGE SHADER
// Wobbles the tree and flashes it upon taking damage
// ---

uniform float flash_amount = 1.0;
uniform float shake_amount = 10.0;
uniform float alpha = 1.0;
uniform vec2 pos = vec2(0.0, 0.0);
uniform bool dehydrated = false;

uniform float uv_y_offset = 0.4;
uniform vec3 flash_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 tint_color: source_color = vec3(1.0, 1.0, 1.0);

uniform float fps;
uniform int frame_count;

uniform float outline_alpha = 0.0;
uniform int outline_width = 1;

const int SPRITE_SHEET_UNIT_WIDTH = 9;
const int SPRITE_SHEET_UNIT_HEIGHT = 2;
const float UNIT_PIXEL_WIDTH = 32.0;
const float UNIT_PIXEL_HEIGHT = 64.0;
const float SPRITE_SHEET_WIDTH = UNIT_PIXEL_WIDTH * float(SPRITE_SHEET_UNIT_WIDTH);
const float SPRITE_SHEET_HEIGHT = UNIT_PIXEL_HEIGHT * float(SPRITE_SHEET_UNIT_HEIGHT);

vec4 flash(vec4 base_color, float amount) {
	return mix(base_color, vec4(flash_color, base_color.a), min(flash_amount, 1.0));
}

float round_to_x_pixel(float x) {
	float new_x = round(x * SPRITE_SHEET_WIDTH) / SPRITE_SHEET_WIDTH;
	return new_x;
}

float round_to_y_pixel(float y) {
	float new_y = floor(y * SPRITE_SHEET_HEIGHT) / SPRITE_SHEET_HEIGHT;
	return new_y;
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

bool is_on_edge(vec2 uv, sampler2D texture2d, vec2 texture_pixel_size) {
	vec4 color = texture(texture2d, uv);
	
	if (color.a > 0.0) {
		return false;
	}
	
	for (int x = -outline_width; x <= outline_width; x++) {
		for (int y = -outline_width; y <= outline_width; y++) {
			if (abs(float(x)) + abs(float(y)) > float(outline_width)) { // For diamond shaped edge detection
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
	vec2 rounded_uv = vec2(round_to_x_pixel(UV.x), round_to_y_pixel(UV.y));

	// SELECTING BETWEEN WIND AND SHAKE!

	float y_falloff_factor = max(1.0 - round_to_y_pixel(UV.y) - uv_y_offset, 0.0);

	float shake = shake_amount / 20.0;
	//float random = noise(vec2(0.0, rounded_uv.y + TIME) * 25.0);

	float sin_value = sin(max(shake * 1.0, 1.0) * TIME * 1.0) / 100.0 * (max(shake * 3.0, 1.0));
	// 15
	// FIGURE OUT HOW TO BETTER COEXIST WIND AND SHAKE...
	vec2 new_uv = UV + vec2(sin_value * y_falloff_factor, 0.0);

	COLOR = texture(TEXTURE, new_uv); // Read from texture

	if (COLOR.a > 0.0) {
 		COLOR = vec4(flash(COLOR, flash_amount).rgb, alpha);
	} else {
 		COLOR = vec4(flash(COLOR, flash_amount).rgb, 0.0);
	}

	//COLOR = COLOR * vec4(tint_color, COLOR.a);

	// BROWNING?
	if (COLOR.g > 0.3 && COLOR.a > 0.0 && dehydrated) {
		COLOR.rgb = mix(COLOR.rgb, vec3(0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b), 1);
		COLOR *= vec4(tint_color, 1.0);
	}
	
	if (is_on_edge(new_uv, TEXTURE, TEXTURE_PIXEL_SIZE)) {
		COLOR = vec4(1.0, 1.0, 1.0, outline_alpha);
	}
	
	//COLOR = vec4(random, 0.0, 0.0, 1.0);
	//COLOR = vec4(0.0, 1.0 - UV.y - 0.2, 0.0, 1.0);
}
