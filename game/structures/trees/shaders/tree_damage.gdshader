shader_type canvas_item;

// ---
// TREE SHADER
// Core shader for all tree sprites
// Handles:
// - Gently wobbling the tree from wind
// - Fiercely wobbling the tree upon taking damage
// - Flashing
// - Tinting
// ---

uniform vec2 pos = vec2(0.0, 0.0); // For noise/variation

// WIND DETAILS
uniform float wind_amount = 1.0; // Ideally [0, 1]

// DAMAGE (SHAKE + FLASH)
uniform float flash_amount = 1.0; // [0, 1], lerp from regular to flash colour
uniform float shake_amount = 10.0;
uniform float tint_amount = 0.0; // [0, 1], lerp between application of tint to greens
uniform float alpha = 1.0; // For modulation

// UV OFFSET
// (So the bottom trunk of the tree does not move)
uniform float uv_y_offset = 0.4;

// COLOURS
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

/* ROUNDING */
// BUG: Maybe this doesn't work if the sheet size changes...
float round_to_x_pixel(float x) {
	float new_x = round(x * SPRITE_SHEET_WIDTH) / SPRITE_SHEET_WIDTH;
	return new_x;
}
float round_to_y_pixel(float y) {
	float new_y = floor(y * SPRITE_SHEET_HEIGHT) / SPRITE_SHEET_HEIGHT;
	return new_y;
}
// Produces the uv rounded to the nearest pixels...
vec2 get_rounded_uv(vec2 uv) {
	return vec2(round_to_x_pixel(uv.x), round_to_y_pixel(uv.y));
}

/* RANDOMNESS */
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
	uv = uv * 0.01;

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

/* OPERATIONS */
vec2 apply_wind_to_uv(vec2 uv, float y_falloff) {
	float rate_shift = noise(pos);
	float phase_shift = rate_shift * random(pos).x * PI;
	//float amp_shift = rate_shift;
	float wind_sin = sin(TIME / 2.0 * noise(pos) + phase_shift) / 35.0;
	return uv + vec2(wind_sin * y_falloff * wind_amount, 0.0);
}

vec2 apply_shake_to_uv(vec2 uv, float y_falloff) {
	return uv + vec2(cos(TIME * 12.0) * 0.03 * y_falloff * shake_amount / 20.0, 0.0);
}

// Lerps to flash based on flash amount
vec4 apply_flash_to_color(vec4 color) {
	return mix(color, vec4(flash_color, color.a), min(flash_amount, 1.0));
}

vec4 to_grayscale(vec4 color, float amount) {
	color.rgb = mix(color.rgb, vec3(0.299 * color.r + 0.587 * color.g + 0.114 * color.b), amount);
	return color;
}

vec4 apply_tint_to_color(vec4 color) {
	// TODO: Make this better using a palette or LUT or something...
	// To accomodate for different types of trees...
	// BROWNING?
	if (color.g > 0.3 && color.a > 0.0) { // Is green leaf
		vec4 tinted_color = to_grayscale(color, 1.0);
		tinted_color *= vec4(tint_color, 1.0);

		color = mix(color, tinted_color, tint_amount);
	}
	return color;
}

/* MAIN */
void fragment() {
	vec2 rounded_uv = get_rounded_uv(UV);
	// FALLOFF (Prevent shaking trunk)
	float y_falloff_factor = max(1.0 - rounded_uv.y - uv_y_offset, 0.0);

	vec2 after_wind = apply_wind_to_uv(UV, y_falloff_factor);
	vec2 after_shake = apply_shake_to_uv(after_wind, y_falloff_factor);

	COLOR = texture(TEXTURE, after_shake); // Read from texture

	vec4 after_flash = apply_flash_to_color(COLOR);
	vec4 after_tint = apply_tint_to_color(after_flash);

 	COLOR = vec4(after_tint.rgb, COLOR.a * alpha);

	if (is_on_edge(after_shake, TEXTURE, TEXTURE_PIXEL_SIZE)) {
		COLOR = vec4(1.0, 1.0, 1.0, outline_alpha);
	}

	//COLOR = vec4(noise(pos), noise(pos), noise(pos), 1.0);
}
