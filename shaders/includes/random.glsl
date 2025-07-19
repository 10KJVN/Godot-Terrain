// pseudo, hash, rand vector

// UE4's PseudoRandom function
// https://github.com/EpicGames/UnrealEngine/blob/release/Engine/Shaders/Private/Random.ush
float pseudo(vec2 v) {
  v = fract(v / 128.) * 128. + vec2(-64.340622, -72.465622);
  return fract(dot(v.xyx * v.xyy, vec3(20.390625, 60.703125, 2.4281209)));
}

// Takes our xz positions and turns them into a random number between 0 and 1
// using the above pseudo random function
float HashPosition(vec2 pos) { return pseudo(pos * vec2(_Seed, _Seed + 4)); }

// Generates a random gradient vector for the perlin noise lattice points, watch
// my perlin noise video for a more in depth explanation
vec2 RandVector(float seed) {
  float theta = seed * 360 * 2 - 360;
  theta += _GradientRotation;
  theta = theta * PI / 180.0;
  return normalize(vec2(cos(theta), sin(theta)));
}