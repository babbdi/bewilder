shader_type sky;

uniform vec3 top_color : source_color = vec3(1.0);
uniform vec3 bottom_color : source_color = vec3(1.0);
uniform sampler2D gradient_curve : repeat_disable, filter_linear;
uniform sampler2D noise_texture : source_color;


uniform sampler2D moon_texture : source_color;
uniform vec3 moon_direction = vec3(1.0, 0.5, 0.0);
uniform float moon_size = 0.05;



void sky() {

	vec3 color_gradient = mix(top_color.rgb, bottom_color.rgb, texture(gradient_curve, vec2(SKY_COORDS.y, 0.0)).x);




    // Calculate dot product between view direction and moon direction
    float dot_product = dot(EYEDIR, normalize(moon_direction));
	float cos_moon_size = cos(moon_size);

    if (dot_product > cos_moon_size) {
        // We're looking at the moon
        vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), moon_direction));
        vec3 up = normalize(cross(moon_direction, right));
        vec2 moon_uv = vec2(
            dot(EYEDIR, right),
            dot(EYEDIR, up)
        ) / sin(moon_size) * 0.5 + 0.5;

        vec4 moon_color = texture(moon_texture, moon_uv);

        float sky_blend = smoothstep(cos_moon_size, cos(moon_size * 0.2), dot_product) * moon_color.a;
        COLOR = mix(color_gradient, moon_color.rgb, sky_blend);
    } else {
        // Regular sky color
		float stars_mask = 1.0-smoothstep(0.36, 0.52, SKY_COORDS.y);
		float stars = texture(noise_texture, SKY_COORDS).r;
		stars = smoothstep(stars, 1.0, 0.6);
		stars *= stars_mask;
		COLOR = color_gradient + vec3(stars);
    }
}
