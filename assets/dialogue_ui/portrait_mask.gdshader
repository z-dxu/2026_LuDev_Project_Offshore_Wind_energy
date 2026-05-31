shader_type canvas_item;

uniform sampler2D mask_texture;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 mask_color = texture(mask_texture, UV);
	COLOR = tex_color;
	COLOR.a *= mask_color.a;
}
