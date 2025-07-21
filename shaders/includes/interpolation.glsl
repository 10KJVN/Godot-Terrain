// quintic interpolation + derivative

// Normal smoothstep is cubic -- to avoid discontinuities in the gradient, we
// use a quintic interpolation instead as explained in my perlin noise video
vec2 quinticInterpolation(vec2 t) {
  return t * t * t * (t * (t * vec2(6) - vec2(15)) + vec2(10));
}

// Derivative of above function
vec2 quinticDerivative(vec2 t) {
  return vec2(30) * t * t * (t * (t - vec2(2)) + vec2(1));
}