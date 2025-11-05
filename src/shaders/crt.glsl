extern number time;
extern number intensity;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    
    // Scanlines
    float scanline = sin(uv.y * 600.0 + time * 10.0) * 0.02 * intensity;
    
    // Chroma aberration (slight color shift)
    float chromaOffset = 0.002 * intensity;
    vec4 texColor = Texel(texture, uv);
    vec2 chromaR = vec2(uv.x + chromaOffset, uv.y);
    vec2 chromaB = vec2(uv.x - chromaOffset, uv.y);
    
    // Get color channels with slight offset
    float r = Texel(texture, chromaR).r;
    float g = texColor.g;
    float b = Texel(texture, chromaB).b;
    
    // Apply scanlines
    vec3 finalColor = vec3(r, g, b) + scanline;
    
    // Slight vignette
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - (dist * 0.3 * intensity);
    
    return vec4(finalColor * vignette, texColor.a) * color;
}

