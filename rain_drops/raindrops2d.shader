shader_type canvas_item;

uniform vec4 water_color : hint_color;
uniform vec4 ring_color : hint_color;
uniform float ring_width : hint_range(0.0, 1.0) = 0.1;
uniform float fadeout : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D pattern;

void fragment() {
	vec2 pat = texture(pattern, UV).rg;
	float grad = pat.r;
	float fct_time = fract(TIME + pat.g);
	float fade = (1.0 - fct_time / fadeout);
	grad -= fct_time;
	grad /= ring_width;
	grad = clamp(grad, 0.0, 1.0);
	float ring = smoothstep(0.0, 1.0, min(grad, (1.0 - grad)) * 2.0);
	ring *= fade;
	ring = clamp(ring, 0.0, 1.0);
	COLOR = vec4(mix(water_color, ring_color, ring).rgb, 1.0);
}