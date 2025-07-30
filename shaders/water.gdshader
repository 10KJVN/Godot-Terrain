shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 water_color : source_color = vec3(0.0, 0.2, 0.5);
uniform float wave_speed = 0.5;
uniform float wave_height = 0.1;
uniform float edge_softness = 0.5;
uniform float transparency = 0.8;
uniform float reflection_intensity = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y += sin(TIME * wave_speed + VERTEX.x * 10.0) * wave_height;
	VERTEX.y += cos(TIME * wave_speed * 0.7 + VERTEX.z * 8.0) * wave_height * 0.7;
}


void fragment() {
	// Called for every pixel the material is visible on.
	float edge_factor = smoothstep(0.0, edge_softness, 1.0 - abs(dot(NORMAL, VIEW)));
	float fresnel = pow(1.0 - max(0.0, dot(NORMAL, VIEW)), 2.0);
	
	vec2 ref_uv = SCREEN_UV - NORMAL.xz * 0.1;
	ref_uv = clamp(ref_uv, vec2(0.001), vec2(0.999));
	
	vec4 screen_color = textureLod(SCREEN_TEXTURE, ref_uv, 0.0);
    vec3 reflection = screen_color.rgb;
	
	ALBEDO = mix(water_color, reflection, fresnel * reflection_intensity);
	ALPHA = transparency * edge_factor;
	METALLIC = 0.2;
	ROUGHNESS = 0.1;
	SPECULAR = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
