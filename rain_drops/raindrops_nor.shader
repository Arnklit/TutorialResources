shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 water_color : hint_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float normal_scale : hint_range(-16.0, 16.0) = 2.0;
uniform float ring_width : hint_range(0.0, 1.0) = 0.1;
uniform float fadeout : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D pattern;

void fragment() {
	vec4 pat = texture(pattern, UV);
	float fct_time = fract(TIME + pat.a);
	float fade = (1.0 - fct_time / fadeout);
	
	float grad_inner = pat.b;
	grad_inner -= fct_time;
	grad_inner /= ring_width / 2.0;
	grad_inner = clamp(grad_inner, 0.0, 1.0);
	float ring_inner = smoothstep(0.0, 1.0, min(grad_inner, (1.0 - grad_inner)) * 2.0);
	ring_inner = clamp(ring_inner, 0.0, 1.0);
	
	float grad_outer = pat.b;
	grad_outer -= fct_time + ring_width / 2.0;
	grad_outer /= ring_width / 2.0;
	grad_outer = clamp(grad_outer, 0.0, 1.0);
	float ring_outer = smoothstep(0.0, 1.0, min(grad_outer, (1.0 - grad_outer)) * 2.0);
	ring_outer = clamp(ring_outer, 0.0, 1.0);
	
	// As our normal map is for the inside of the ring, we make an inverted
	// version for the outside by unpacking, multiplying by -1.0 and repacking
	vec2 inverted_nor = (((pat.rg * 2.0 - 1.0) * -1.0) + 1.0) / 2.0; 
	vec3 normap = mix(vec3(0.5, 0.5, 0.0), vec3(pat.rg, 0.0), ring_inner);
	normap = mix(normap, vec3(inverted_nor, 0.0), ring_outer);
	
	ALBEDO = water_color.rgb;
	ROUGHNESS = roughness;
	NORMALMAP = normap;
	NORMALMAP_DEPTH = clamp(fade, 0.0, 1.0) * normal_scale;
}