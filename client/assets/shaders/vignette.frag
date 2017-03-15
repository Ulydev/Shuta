extern float setting = 1.2;

vec4 effect(vec4 color, Image currentTexture, vec2 texCoords, vec2 screenCoords){
  float dist = distance(texCoords, vec2(.5, .5));
  vec3 pixelColor = Texel(currentTexture, texCoords).xyz * smoothstep(setting, .4, dist);
  return vec4(pixelColor, 1.0);
}