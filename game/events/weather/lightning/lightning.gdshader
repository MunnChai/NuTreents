shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
uniform float speed = 3.0;
uniform float phase_multiplier = 1.0;

// ASSUME SQUARE!!!
uniform int pixel_resolution = 512;
uniform int pixel_width = 8;

uniform sampler2D noise_tex: filter_nearest, repeat_enable;

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
	return texture(noise_tex, uv).x;
    //vec2 uv_index = floor(uv);
    //vec2 uv_fract = fract(uv);
//
    //vec2 blur = smoothstep(0.0, 1.0, uv_fract);
//
    //return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     //dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                //mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     //dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

// ASSUME UV IS FROM 0 to 1
vec2 round_to_nearest_pixel(vec2 uv) {
	float res = float(pixel_resolution);
	vec2 scaled_up = floor(uv * res);
	vec2 scaled_down = scaled_up / res;
	return scaled_down;
}

float round_to_nearest_step(float value, float increment) {
	float divide_and_round = round(value / increment);
	return divide_and_round * increment;
}

void fragment() {
	float time = round_to_nearest_step(TIME, 1.0 / 12.0);

    vec2 uv = 2.0 * round_to_nearest_pixel(UV) - 1.0; // -1 to 1

	float uv_y = uv.y; // -1 to 1

	float percent_to_down = UV.y;

	float percent_to_end = abs(uv_y); // 1.0 at ENDS abs(0.5), 0.0 at MIDDLE abs(0.0)
	float percent_to_middle = 1.0 - percent_to_end; // 0.0 at END, 1.0 at MIDDLE

	// ALL THE NOISE STUFF HAPPENS HERE
	//uv += (2.0 * fbm(uv + TIME * speed, octave_count) - 1.0) * percent_to_middle; // Offset
	float n = (2.0 * noise(vec2(1.0, UV.y) * 0.5 + time * speed * phase_multiplier) - 1.0);
	//float n2 = (2.0 * noise(vec2(0.5, UV.y) * 0.886 + TIME * speed * 2.0) - 1.0);
	uv.x += sin(percent_to_middle * PI / 2.0) * (n) / 5.0; // Offset
	//uv.x += n / 5.0;

    float dist = abs(uv.x); // Distance from 0 (middle)

	//// Amount of UV distance before fall off
	float uv_width = float(pixel_width) * (1.0 / float(pixel_resolution));
	float half_uv_width = uv_width * 2.0;

	float allow_percent = 1.0 - (clamp(dist / half_uv_width, 0.0, 1.0));

	float allow_float = step(0.9, allow_percent);

	COLOR = vec4(allow_float * effect_color, allow_float * percent_to_down);

	//// PURELY COLOUR WITHIN DISTANCE
    //vec3 color = effect_color * allow_percent;
	//
	//float strength = round(length(color)); // Alpha
	//
    //COLOR = vec4(color, strength);
	////COLOR = vec4(abs(uv.x), 1.0, 1.0, 1.0);
}
