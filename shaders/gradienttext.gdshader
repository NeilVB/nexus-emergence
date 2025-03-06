shader_type canvas_item;
render_mode unshaded;
uniform sampler2D gradient : source_color;
uniform float gradient_mix_amount = 1.0;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(cosa * uv.x - sina * uv.y,
				cosa * uv.y + sina * uv.x) + pivot;

}

void fragment() {
	vec2 myUv = rotateUV(UV,vec2(0.1,0.3), radians(90));
	vec3 gradientTex = texture(gradient, myUv).rgb;
	float greyscale_value = dot(gradientTex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 sampled_color = texture(gradient, vec2(greyscale_value, 0.0)).rgb;

	// Mix the gradient texture color, with the sampled color using the gradient mix amount
	COLOR.rgb = mix(gradientTex.rgb, sampled_color, gradient_mix_amount);
	// Get the pixel alpha value from the texture
	vec4 pixelColor = texture(TEXTURE,UV);
	// Preserve the alpha value of the texture
	COLOR.a = pixelColor.a;
}