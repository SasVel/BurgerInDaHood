shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform float black_bars_thickness : hint_range(0.0, 3.0, 0.1) = 2.0;
uniform float white : hint_range(0.0, 2.0, 0.1) = 1.4;
uniform float opacity : hint_range(0.0, 1.0, 0.1) = 1;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float isOn : hint_range(0.0, 1.0, 1.0) = 1.0;

void fragment()
{
	//If you dont want scanlines you can just delete this part
	float s = sin(SCREEN_UV.y * scanline_count * PI * black_bars_thickness);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25)), opacity);

	vec4 finalTexture = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = (finalTexture * (scan_line * white)) * isOn;
}