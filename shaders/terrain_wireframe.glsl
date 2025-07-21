#version 450

layout(set = 0, binding = 0, std140) uniform UniformBufferObject {
  mat4 MVP;
  mat4 MODEL_MATRIX;
  vec4 _LowSlopeColor;
  vec4 _HighSlopeColor;
  vec4 _AmbientLight;
  vec4 fog_color;
  vec3 _LightDirection;
  float _GradientRotation;
  vec3 _Offset;
  float _NoiseRotation;
  vec3 camera_position;
  float _TerrainHeight;
  vec2 _AngularVariance;
  vec2 _SlopeRange;
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

layout(location = 2) in vec4 a_Color;

layout(location = 0) out vec4 frag_color;

void main() { frag_color = vec4(1, 0, 0, 1); }