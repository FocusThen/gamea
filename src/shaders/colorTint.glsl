extern vec3 tintColor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // Get texture color (for shapes, this is a 1x1 white texture)
    vec4 texColor = Texel(texture, texture_coords);
    
    // Combine texture color with drawing color (standard Love2D pattern)
    vec4 combinedColor = texColor * color;
    
    // Apply color overlay: multiply combined color with tint color
    // This creates an overlay effect where the tint color is applied on top
    vec3 tinted = combinedColor.rgb * tintColor;
    
    // Preserve original alpha
    return vec4(tinted, combinedColor.a);
}

