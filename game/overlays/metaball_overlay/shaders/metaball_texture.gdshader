shader_type canvas_item;

uniform vec4 override_color: source_color;
uniform sampler2D gradient;

// ALPHA GRADIENT PSEUDO-METABALLS for TEXTURE
// Based on https://john-wigg.dev/2DMetaballs/

void fragment() {
	float r = texture(TEXTURE, UV).r;
	float g = texture(TEXTURE, UV).g;
	float b = texture(TEXTURE, UV).b;

	vec4 proper = texture(gradient, vec2(b, 0.0f));
	float alpha = proper.a;
	vec4 override_proper = vec4(override_color.rgb, alpha);
	vec4 color = mix(proper, override_proper, r);

	COLOR = color;
}