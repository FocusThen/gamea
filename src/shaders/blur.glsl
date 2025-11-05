extern vec2 direction;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 c = vec4(0.0);
    
    // Simple 9-tap Gaussian blur
    c += Texel(texture, texture_coords + vec2(-4.0, -4.0) * direction) * 0.01621622;
    c += Texel(texture, texture_coords + vec2(-3.0, -3.0) * direction) * 0.05405405;
    c += Texel(texture, texture_coords + vec2(-2.0, -2.0) * direction) * 0.12162162;
    c += Texel(texture, texture_coords + vec2(-1.0, -1.0) * direction) * 0.19459459;
    c += Texel(texture, texture_coords) * 0.22702703;
    c += Texel(texture, texture_coords + vec2(1.0, 1.0) * direction) * 0.19459459;
    c += Texel(texture, texture_coords + vec2(2.0, 2.0) * direction) * 0.12162162;
    c += Texel(texture, texture_coords + vec2(3.0, 3.0) * direction) * 0.05405405;
    c += Texel(texture, texture_coords + vec2(4.0, 4.0) * direction) * 0.01621622;
    
    return c * color;
}

