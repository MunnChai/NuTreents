shader_type canvas_item;

uniform sampler2D gradient;

// ALPHA GRADIENT PSEUDO-METABALLS for TEXTURE
// Based on https://john-wigg.dev/2DMetaballs/

void fragment() {
	float b = texture(TEXTURE, UV).r;
	COLOR = texture(gradient, vec2(b, 0.0f));
}