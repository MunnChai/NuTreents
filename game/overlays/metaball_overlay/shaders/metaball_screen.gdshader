shader_type canvas_item;
render_mode unshaded;

// SCREEN TEXTURE METABALL SHADER
// Based on https://github.com/latenitecali/godot-metaball/blob/master/metaball.shader

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform int blurSize : hint_range(0,45) = 45;

void fragment() {
	// this blur depends on the zoom of the screen, so not perfect for getting the right results all the time
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, float(blurSize)/10.0);

	float alpha = 1.0;
	vec3 color = texture(TEXTURE, UV).rgb;
	float average = (COLOR.r + COLOR.g + COLOR.b) / 3.0;

	alpha = step(0.3 + sin(TIME * PI / 2.0) / 35.0, average);

	COLOR = vec4(color, alpha);
}