#version 450

#define PI 3.141592653589793238462
// This is the uniform buffer that contains all of the settings we sent over
// from the cpu in _render_callback. Must match with the one in the fragment
// shader.
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

#include "random.glsl"
#include "interpolation.glsl"
#include "noise.glsl"

// This is the vertex data layout that we defined in initialize_render after
// line 198
layout(location = 0) in vec3 a_Position;
layout(location = 1) in vec4 a_Color;

// This is what the vertex shader will output and send to the fragment shader.
layout(location = 2) out vec4 v_Color;
layout(location = 3) out vec3 pos;
layout(location = 4) out vec3 frag_world_pos;
layout(location = 5) out vec3 view_dir;


void main() {
  // Passes the vertex color over to the fragment shader, even though we don't
  // use it but you can use it if you want I guess
  v_Color = a_Color;
  frag_world_pos = (MODEL_MATRIX * vec4(a_Position, 1.0)).xyz;
  view_dir = normalize(camera_position - frag_world_pos);

  // The fragment shader also calculates the fractional brownian motion for
  // pixel perfect normal vectors and lighting, so we pass the vertex position
  // to the fragment shader
  pos = a_Position;

  // Initial noise sample position offset and scaled by uniform variables
  vec3 noise_pos = (pos + vec3(_Offset.x, 0, _Offset.z)) / _Scale;

  // The fractional brownian motion
  vec3 n = fbm(noise_pos.xz);

  // Adjust height of the vertex by fbm result scaled by final desired amplitude
  pos.y += _TerrainHeight * n.x + _TerrainHeight - _Offset.y;

  // Multiply final vertex position with model/view/projection matrices to
  // convert to clip space
  gl_Position = MVP * vec4(pos, 1);
}