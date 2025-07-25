// perlin_noise2D

// Improved Random Functions

// Integer hash function from PCG
uvec3 pcg3d(uvec3 p) {
  p = p * 1664525u + 1013904223u;
  p.x += p.y * p.z;
  p.y += p.z * p.x;
  p.z += p.x * p.y;
  p ^= p >> 16u;
  p += p >> 8u;
  return p;
}

// Float version normalized to [0, 1)
vec3 hash33(vec3 p) {
  uvec3 n = floatBitsToUint(p);
  return vec3(pcg3d(n)) / float(0xffffffffu);
}

// 2D to 3D position converter for hashing
vec3 vec2_to_vec3(vec2 p) {
  return vec3(p, _Seed); // _Seed = global uniform
}

// Convert hash to angle gradient
vec2 angle_gradient(vec2 pos) {
  float angle = hash33(vec2_to_vec3(pos)).x * 6.2831853; // 2 pi
  return vec2(cos(angle), sin(angle));
}

// it's perlin noise that returns the noise in the x component and the
// derivatives in the yz components as explained in my perlin noise video
vec3 perlin_noise2D(vec2 pos) {
  vec2 latticeMin = floor(pos);
  vec2 latticeMax = ceil(pos);

  vec2 remainder = fract(pos);

  // Lattice Corners
  vec2 c00 = latticeMin;
  vec2 c10 = vec2(latticeMax.x, latticeMin.y);
  vec2 c01 = vec2(latticeMin.x, latticeMax.y);
  vec2 c11 = latticeMax;

  // Gradient Vectors assigned to each corner
  vec2 g00 = angle_gradient(c00);
  vec2 g10 = angle_gradient(c10);
  vec2 g01 = angle_gradient(c01);
  vec2 g11 = angle_gradient(c11);

  // Directions to position from lattice corners
  vec2 p0 = remainder;
  vec2 p1 = p0 - vec2(1.0);

  vec2 p00 = p0;
  vec2 p10 = vec2(p1.x, p0.y);
  vec2 p01 = vec2(p0.x, p1.y);
  vec2 p11 = p1;

  vec2 u = quinticInterpolation(remainder);
  vec2 du = quinticDerivative(remainder);

  float a = dot(g00, p00);
  float b = dot(g10, p10);
  float c = dot(g01, p01);
  float d = dot(g11, p11);

  // Expanded interpolation freaks of nature from
  // https://iquilezles.org/articles/gradientnoise/
  float noise = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);

  vec2 gradient = g00 + u.x * (g10 - g00) + u.y * (g01 - g00) +
                  u.x * u.y * (g00 - g10 - g01 + g11) +
                  du * (u.yx * (a - b - c + d) + vec2(b, c) - a);
  return vec3(noise, gradient);
}

// The fractional brownian motion that sums many noise values as explained in
// the video accompanying this project    
vec3 fbm(vec2 pos) {
  float lacunarity = _Lacunarity;
  float amplitude = _InitialAmplitude;

  // height sum
  float height = 0.0;

  // derivative sum
  vec2 grad = vec2(0.0);

  // accumulated rotations
  mat2 m = mat2(1.0, 0.0, 0.0, 1.0);

  // generate random angle variance if applicable
  float angle_variance = mix(_AngularVariance.x, _AngularVariance.y,
                             HashPosition(vec2(_Seed, 827)));
  float theta = (_NoiseRotation + angle_variance) * PI / 180.0;

  // rotation matrix
  mat2 m2 = mat2(cos(theta), -sin(theta), sin(theta), cos(theta));

  mat2 m2i = inverse(m2);

  for (int i = 0; i < int(_Octaves); ++i) {
    vec3 n = perlin_noise2D(pos);

    // add height scaled by current amplitude
    height += amplitude * n.x;

    // add gradient scaled by amplitude and transformed by accumulated rotations
    grad += amplitude * m * n.yz;

    // apply amplitude decay to reduce impact of next noise layer
    amplitude *= _AmplitudeDecay;

    // generate random angle variance if applicable
    angle_variance = mix(_AngularVariance.x, _AngularVariance.y,
                         HashPosition(vec2(i * 419, _Seed)));
    theta = (_NoiseRotation + angle_variance) * PI / 180.0;

    // reconstruct rotation matrix, kind of a performance stink since this is
    // technically expensive and doesn't need to be done if no random angle
    // variance but whatever it's 2025
    m2 = mat2(cos(theta), -sin(theta), sin(theta), cos(theta));

    m2i = inverse(m2);

    // generate frequency variance if applicable
    float freq_variance =
        mix(_FrequencyVarianceLowerBound, _FrequencyVarianceUpperBound,
            HashPosition(vec2(i * 422, _Seed)));

    // apply frequency adjustment to sample position for next noise layer
    pos = (lacunarity + freq_variance) * m2 * pos;
    m = (lacunarity + freq_variance) * m2i * m;
  } 
return vec3(height, grad);
}