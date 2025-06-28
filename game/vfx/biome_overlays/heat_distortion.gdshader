shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float strength = 0.002;
uniform float speed = 10.0;
uniform float freq = 10.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv += vec2(sin(TIME * speed + uv.y * freq) * strength, 0.0);
	vec2 real_uv = uv;

    COLOR = textureLod(screen_texture, real_uv, 0.0);
}