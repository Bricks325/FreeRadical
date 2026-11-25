shader_type canvas_item;
/** 灰度着色器。 */

/** 强度。 */
uniform float strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec3 luma = vec3(0.299, 0.587, 0.114);
    float gray = dot(COLOR.rgb, luma);
	vec3 gray_color = vec3(gray);
	COLOR.rgb = mix(COLOR.rgb, gray_color, strength);
}