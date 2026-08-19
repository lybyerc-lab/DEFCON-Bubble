shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_burley, specular_schlick_ggx;

// [DB:PRESENTATION:SOAP_FILM]
// One shared soap-film surface for the whole bubble-monster family. The body and
// every limb, foot, and horn use this shader so a creature reads as one substance.
// Callers tint it through base_color and iridescence_intensity; nothing here owns
// gameplay truth.
//
// This shader is lit on purpose. It leans on SPECULAR, low ROUGHNESS, and fresnel,
// so it only pays off when the scene supplies a sky and ambient term to reflect.

uniform vec4 base_color : source_color = vec4(0.74, 0.91, 1.0, 0.085);
uniform float iridescence_intensity : hint_range(0.0, 1.0) = 0.64;
uniform float fresnel_power : hint_range(0.1, 5.0) = 2.35;

varying vec3 object_position;

vec3 film_spectrum(float phase) {
	float r = sin(phase * 6.2831853 + 0.0) * 0.5 + 0.5;
	float g = sin(phase * 6.2831853 + 2.0943951) * 0.5 + 0.5;
	float b = sin(phase * 6.2831853 + 4.1887902) * 0.5 + 0.5;
	return vec3(r, g, b);
}

void vertex() {
	// VERTEX is model/object space here. Carry it explicitly into fragment() so
	// the thin-film pattern belongs to the bubble instead of the camera.
	object_position = VERTEX;
}

void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - facing, fresnel_power);

	// Slow overlapping waves approximate changing soap-film thickness. The motion
	// is intentionally restrained: shimmer, not a neon animated texture.
	float wave_a = sin(object_position.y * 5.1 + object_position.x * 2.4 + TIME * 0.55);
	float wave_b = cos(object_position.x * 3.7 - object_position.z * 4.2 + TIME * 0.37);
	float film_wave = (wave_a + wave_b) * 0.5;
	float phase = fresnel * 0.82 + film_wave * 0.075 + object_position.y * 0.055;
	vec3 rainbow = film_spectrum(phase);

	float iridescent_mix = clamp(fresnel * iridescence_intensity + abs(film_wave) * 0.045, 0.0, 0.72);
	ALBEDO = mix(base_color.rgb, rainbow, iridescent_mix);
	ROUGHNESS = 0.035;
	METALLIC = 0.0;
	SPECULAR = 0.72;
	EMISSION = rainbow * fresnel * 0.025;

	// A soap bubble is mostly absent in the center and readable at grazing angles.
	float center_variation = (film_wave * 0.5 + 0.5) * 0.025;
	ALPHA = clamp(base_color.a + center_variation + fresnel * 0.50, 0.065, 0.64);
}
