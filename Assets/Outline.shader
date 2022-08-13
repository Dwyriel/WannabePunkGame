shader_type canvas_item;

uniform vec4 lineColor : hint_color = vec4(1.0);
uniform float lineThickness : hint_range(0, 10);

const vec2 OFFSET[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment(){
	vec2 size = TEXTURE_PIXEL_SIZE * lineThickness;
	float outline = .0;
	for (int i = 0; i < OFFSET.length(); i++)
		outline += texture(TEXTURE, UV + size * OFFSET[i]).a;
	outline = min(outline, 1.0);
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, lineColor, outline - color.a);
}