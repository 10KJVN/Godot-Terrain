#version 450

// Constants
#define PI 3.141592653589793238462

// Uniforms
layout(set = 0, binding = 0, std140) uniform UniformBufferObject {
  mat4 MVP;
  mat4 MODEL_MATRIX;  // 16

  vec4 _LowSlopeColor;
  vec4 _HighSlopeColor;
  vec4 _AmbientLight;
  vec4 fog_color;  // 4

  vec3 _LightDirection;
  float _GradientRotation;

  vec3 _Offset;
  float _NoiseRotation;

  vec3 camera_position;
  float _TerrainHeight;  // 3 + 1

  vec2 _AngularVariance;
  vec2 _SlopeRange;  // 2 + 2

  float _Scale;
  float _Octaves;
  float _AmplitudeDecay;
  float _NormalStrength;

  float _Seed;
  float _InitialAmplitude;
  float _Lacunarity;
  float _SlopeDamping;

  float _FrequencyVarianceLowerBound;
  float _FrequencyVarianceUpperBound;

  float fog_start;
  float fog_density;
  float fog_height_fade;

  vec3 _LightColor;
  float _LightIntensity;
  float _SpecularStrength;
  float _Shininess;
};


// These are the variables that we expect to receive from the vertex shader - Inputs
layout(location = 2) in vec4 a_Color;
layout(location = 3) in vec3 pos;
layout(location = 4) in vec3 frag_world_pos;
layout(location = 5) in vec3 view_dir;

// This is what the fragment shader will output, usually just a pixel color - Output
layout(location = 0) out vec4 frag_color;

// Includes
#include "random.glsl"
#include "interpolation.glsl"
#include "noise.glsl"

void main() {
    // World and Noise Setup
    vec3 noise_pos = (pos + vec3(_Offset.x, 0, _Offset.z)) / _Scale;
    vec3 n = _TerrainHeight * fbm(noise_pos.xz);
    
    // Slope + Material Color
    vec3 slope_normal = normalize(vec3(-n.y, 1, -n.z) * vec3(_SlopeDamping, 1, _SlopeDamping));
    float material_blend_factor = smoothstep(_SlopeRange.x, _SlopeRange.y, 1.0 - slope_normal.y);
    vec4 albedo = mix(_LowSlopeColor, _HighSlopeColor, vec4(material_blend_factor));

    // LOD Factor
    float dist = length(frag_world_pos - camera_position);
    float raw_dist = max(0.0, dist - fog_start);
    float lod_factor = smoothstep(20.0, 80.0, raw_dist);
    // TODO: Extend LOD to affect noise octaves or skip heavy effects.
    // e.g. reduce '_Octaves' or skip slope coloring/lighting if 'lod_factor' > 0.8

    // Lighting: Blinn-Phong
    vec3 normal = normalize(vec3(-n.y, 1, -n.z));
    vec3 lod_normal = normalize(mix(normal, vec3(0, 1, 0), lod_factor));
    vec3 light_dir = normalize(_LightDirection);
    vec3 view_direction = normalize(view_dir);
    vec3 half_vector = normalize(light_dir + view_direction);

    // Diffuse
    float ndotl = clamp(dot(light_dir, lod_normal), 0.0, 1.0);
    vec4 diffuse = albedo * ndotl;

    // Specular
    float spec_angle = clamp(dot(lod_normal, half_vector), 0.0, 1.0);
    float specular_strength = pow(spec_angle, 32.0); // 32 = sharpness
    vec4 specular = vec4(vec3(specular_strength * 0.3), 0.0); // 0.3 = intensity

    // Ambient
    vec4 ambient = albedo * _AmbientLight;

    // Combine lighting
    vec4 lit = clamp(diffuse + specular + ambient, 0.0, 1.0);
    lit = pow(lit, vec4(2.2)); // gamma correction

    // Fog
    float fog_dist = max(0.0, raw_dist - fog_start);
    float height_factor = clamp(1.0 - fog_height_fade * (frag_world_pos.y / _TerrainHeight), 0.0, 1.0);
    float density = fog_density * height_factor;
    float transmittance = exp(-fog_dist * density);

    // Output
    frag_color = mix(fog_color, lit, transmittance);

    // DEBUG Outputs
    //frag_color = vec4(vec3(1.0 - lod_factor), 1.0); // LOD visualizer

    /*vec3 highlight = vec3(pow(max(dot(normal, normalize(_LightDirection + view_dir)), 0.0), 16.0));
    frag_color = vec4(highlight, 1.0);*/ //  Blinn-Phong visualizer
    
}