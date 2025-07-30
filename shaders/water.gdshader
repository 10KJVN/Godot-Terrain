shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 water_color : source_color = vec3(0.0, 0.2, 0.5);
uniform float wave_speed = 0.5;
uniform float wave_height = 0.1;

// Sky3D connection with proper time handling
uniform vec3 sun_direction = vec3(0.0, 1.0, 0.0);
uniform vec3 sun_color = vec3(1.0);
uniform float sun_energy = 1.0;
uniform vec3 ambient_light = vec3(0.2);
uniform float time_of_day = 0.5; // 0-1 range (0=midnight, 0.5=noon)

// Moon lighting (optional)
uniform vec3 moon_direction = vec3(0.0, -1.0, 0.0);
uniform vec3 moon_color = vec3(0.8, 0.85, 1.0);

void vertex() {
    // Wave animation with time-of-day influence
    float wave_strength = mix(0.7, 1.2, smoothstep(0.4, 0.6, time_of_day));
    VERTEX.y += sin(TIME * wave_speed + VERTEX.x * 10.0) * wave_height * wave_strength;
    VERTEX.y += cos(TIME * wave_speed * 0.7 + VERTEX.z * 8.0) * wave_height * 0.7 * wave_strength;
}

void fragment() {
	float day_intensity = smoothstep(0.4, 0.6, time_of_day); // Smoother day/night transition
	float night_visibility = 0.3; // Minimum visibility at night (30% of base color)
    
    // Sample reflection
    vec2 ref_uv = SCREEN_UV - NORMAL.xz * mix(0.05, 0.15, day_intensity);
    ref_uv = clamp(ref_uv, vec2(0.001), vec2(0.999));
    vec3 reflection = textureLod(SCREEN_TEXTURE, ref_uv, 0.0).rgb;
    
    // Calculate lighting contributions
    vec3 night_color = water_color * vec3(0.5, 0.6, 0.8); // Blue-ish tint at night
	vec3 base_color = mix(night_color, water_color, day_intensity);
    vec3 ambient = ambient_light * mix(0.8, 0.3, day_intensity);
    
    // Fresnel effect
    float fresnel = pow(1.0 - max(0.0, dot(NORMAL, VIEW)), 2.0);
    
    // Final color composition
    ALBEDO = mix(
        water_color * ambient,
        reflection * (base_color + ambient),
        fresnel
    );
    
    // Dynamic transparency
    ALPHA = mix(0.7, 0.85, day_intensity);
    
    // Material properties
    METALLIC = mix(0.1, 0.3, day_intensity);
    ROUGHNESS = mix(0.15, 0.1, day_intensity); // Smoother during day
    SPECULAR = mix(0.3, 0.5, day_intensity);
}