shader_type canvas_item;

uniform float factor : hint_range(0, 10) = 2;

void fragment(){
	vec2 numOfPixels = vec2(textureSize(TEXTURE, 0)) * factor;
	vec2 pixelatedUV = round(UV * numOfPixels) / factor;
	COLOR = vec4(pixelatedUV.x, pixelatedUV.y, 0 , 1);
}