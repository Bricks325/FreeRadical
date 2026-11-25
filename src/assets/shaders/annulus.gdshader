shader_type canvas_item;
/** 圆环着色器，支持渐变描边。*/

/** 中点。*/
uniform vec2 center = vec2(0.5);
/** 颜色。*/
uniform vec3 color: source_color = vec3(0.325, 0.745, 0.055);
/** 外径。*/
uniform float outer_radius: hint_range(0, 0.5, 0.01) = 0.5;
/** 内径。*/
uniform float inner_radius: hint_range(0, 0.5, 0.01) = 0;
/** 渐变内径，会考虑内径来确保平滑渐变。*/
uniform float gradient_inner_radius: hint_range(0, 0.5, 0.01) = 0;

void fragment() {
	COLOR.rgb = color;
	
	float dist = distance(UV, center);
	float mask = step(dist, outer_radius);
	COLOR.a = mask;
	
	float min_range = max(0, gradient_inner_radius - inner_radius);
	float max_range = max(0, outer_radius - inner_radius);
	float alpha = pow(smoothstep(min_range, max_range, dist), 2);
	COLOR.a *= alpha;
}