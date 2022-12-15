// 2022 Kasper Arnklit Frandsen - Public Domain - No Rights Reserved

// WORLD NORMAL MIX SHADER
// This shader can  be used to mix two PBR materials based on a world normal. This is useful for
// effects such as snow on top of an object, or grass growing on top of an object.

// COMMENTS:
// LINE 43 - We unpack the background normal map.
// LINE 44 - Recalculate z-component of the normal map with the Pythagorean theorem.
// LINE 45 - Apply the tangent-space normal map to the view-space normals.
// LINE 46 - Convert the world up vector into view-space with a matrix multiplication.
// LINE 47 - Compare the up vector to the surface with the normal map applied using the dot product.
// LINE 48 - Remap the dot-product to a clamped mask using the smoothstep function.
// LINE 50 - Mix the various textures and apply them, using the mask.

shader_type spatial;

uniform float offset : hint_range(-1.0, 1.0) = 0.5;
uniform float fade : hint_range(0.0, 1.0) = 0.1;

uniform vec3 uv_scale_fg = vec3(1.0);
uniform vec3 uv_scale_bg = vec3(1.0);

uniform sampler2D albedo_texture_fg : hint_default_white;
uniform sampler2D orm_texture_fg : hint_default_white;
uniform sampler2D normal_texture_fg : hint_normal;

uniform sampler2D albedo_texture_bg : hint_default_white;
uniform sampler2D orm_texture_bg : hint_default_white;
uniform sampler2D normal_texture_bg : hint_normal;

void fragment() {
	vec2 fg_uv = UV * uv_scale_fg.xy;
	vec2 bg_uv = UV * uv_scale_bg.xy;
	vec3 albedo_tex_fg = texture(albedo_texture_fg, fg_uv).rgb;
	vec3 orm_tex_fg = texture(orm_texture_fg, fg_uv).rgb;
	vec3 normal_tex_fg = texture(normal_texture_fg, fg_uv).rgb;
	
	vec3 albedo_tex_bg = texture(albedo_texture_bg, bg_uv).rgb;
	vec3 orm_tex_bg = texture(orm_texture_bg, bg_uv).rgb;
	vec3 normal_tex_bg = texture(normal_texture_bg, bg_uv).rgb;
	
	vec3 bg_normal = normal_tex_bg * 2.0 - 1.0;
	bg_normal.z = sqrt(1.0 - bg_normal.x * bg_normal.x - bg_normal.y * bg_normal.y);
	vec3 normal_applied = bg_normal.x * TANGENT + bg_normal.y * BINORMAL + bg_normal.z * NORMAL;
	vec3 up_vector_viewspace = mat3(VIEW_MATRIX) * vec3(0.0, 1.0, 0.0);
	float dot_product = dot(up_vector_viewspace, normal_applied);
	float mask = smoothstep(offset - fade, offset + fade, dot_product);

	ALBEDO = mix(albedo_tex_bg, albedo_tex_fg, mask);
	vec3 mixed_orm = mix(orm_tex_bg, orm_tex_fg, mask);
	AO = mixed_orm.r;
	ROUGHNESS = mixed_orm.g;
	METALLIC = mixed_orm.b;
	NORMAL_MAP = mix(normal_tex_bg, normal_tex_fg, mask);
}