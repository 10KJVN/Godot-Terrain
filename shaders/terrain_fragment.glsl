#version 450

#define PI 3.141592653589793238462
// This is the uniform buffer that contains all of the settings we sent over
// from the cpu in _render_callback. Must match with the one in the vertex
// shader, they're technically the same thing occupying the same spot in memory
// this is just duplicate code required for compilation.
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
};

#include "random.glsl"
#include "interpolation.glsl"
#include "noise.glsl"

// These are the variables that we expect to receive from the vertex shader
layout(location = 2) in vec4 a_Color;
layout(location = 3) in vec3 pos;
layout(location = 4) in vec3 frag_world_pos;

// This is what the fragment shader will output, usually just a pixel color
layout(location = 0) out vec4 frag_color;


void main() {
  // Recalculate initial noise sampling position same as vertex shader
  vec3 noise_pos = (pos + vec3(_Offset.x, 0, _Offset.z)) / _Scale;

  // Calculate fbm, we don't care about the height just the derivatives here for
  // the normal vector so the ` + _TerrainHeight - _Offset.y` drops off as it
  // isn't relevant to the derivative
  vec3 n = _TerrainHeight * fbm(noise_pos.xz);

  // To more easily customize the color slope blending this is a separate normal
  // vector with its horizontal gradients significantly reduced so the normal
  // points upwards more
  vec3 slope_normal =
      normalize(vec3(-n.y, 1, -n.z) * vec3(_SlopeDamping, 1, _SlopeDamping));

  // Use the slope of the above normal to create the blend value between the two
  // terrain colors
  float material_blend_factor =
      smoothstep(_SlopeRange.x, _SlopeRange.y, 1 - slope_normal.y);

  // Blend between the two terrain colors
  vec4 albedo =
      mix(_LowSlopeColor, _HighSlopeColor, vec4(material_blend_factor));

  // This is the actual surface normal vector
  vec3 normal = normalize(vec3(-n.y, 1, -n.z));

  // Lambertian diffuse, negative dot product values clamped off because
  // negative light doesn't exist
  float ndotl = clamp(dot(_LightDirection, normal), 0, 1);

  // Direct light cares about the diffuse result, ambient light does not
  vec4 direct_light = albedo * ndotl;
  vec4 ambient_light = albedo * _AmbientLight;

  // Combine lighting values, clip to prevent pixel values greater than 1 which
  // would really really mess up the gamma correction below
  vec4 lit = clamp(direct_light + ambient_light, vec4(0), vec4(1));

  // Convert from linear rgb to srgb for proper color output, ideally you'd do
  // this as some final post processing effect because otherwise you will need
  // to revert this gamma correction elsewhere
  frag_color = pow(lit, vec4(2.2));

  lit = pow(lit, vec4(2.2));  // Gamma correct

  // Fog
  float dist = length(frag_world_pos - camera_position);
  dist = max(0.0, dist - fog_start);

  // LOD factor based on distance
  float lod_factor = smoothstep(20.0, 80.0, dist);

  float height_factor = clamp(
      1.0 - fog_height_fade * (frag_world_pos.y / _TerrainHeight), 0.0, 1.0);
  float density = fog_density * height_factor;

  // Compute Beer's Law transmittance:
  float transmittance = exp(-dist * density);

  frag_color = mix(fog_color, lit, transmittance);
}