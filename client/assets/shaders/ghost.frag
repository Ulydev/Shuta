extern vec4 Color;
vec4 effect( vec4 color, Image tex, vec2 tex_uv, vec2 pix_uv )
{  
  vec4 tcolor = Texel(tex, tex_uv);
  return tcolor * Color;
}