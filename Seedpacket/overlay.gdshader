shader_type canvas_item;

uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Keep the original alpha/shape, replace the RGB.
    COLOR = vec4(overlay_color.rgb, tex.a * overlay_color.a);
}
