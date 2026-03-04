shader_type spatial;


uniform sampler2D vertex_noise1;
uniform sampler2D vertex_noise2;

uniform float bend_strength = 0.9;
uniform float noise_scale = 0.3;
uniform float time_speed = 0.3;

void vertex() {
    // Мировая позиция вершины
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Координаты для шума (зависят от мира)
    vec2 noise_uv = world_pos.xz * noise_scale
                  + vec2(TIME * time_speed, TIME * time_speed);

    float n1 = texture(vertex_noise1, noise_uv).r;
    float n2 = texture(vertex_noise2, noise_uv * 1.7).r;

    // Высота влияет на силу отклонения (пламя гнётся сильнее сверху)
    float height_factor = clamp(VERTEX.y, 0.0, 1.0);

    // Направление отклонения
    vec2 bend_dir = vec2(n1 - 0.5, n2 - 0.5);

    // Смещение вершины
    VERTEX.xz += bend_dir * bend_strength * height_factor;
}

uniform sampler2D noise1;
uniform sampler2D noise2;

uniform float speed = 0.8;
uniform float scale = 2.0;
uniform float distortion = 0.3;

void fragment() {
    // Бесшов по X
    vec2 uv = UV;
    uv.x = fract(uv.x);

    // Подъём огня
    uv.y += TIME * speed;

    // Первый шум — форма пламени
    float n1 = texture(noise1, uv * scale).r;

    // Второй шум — искажение
    vec2 warp_uv = uv * scale;
    warp_uv.x += n1 * distortion;
    float n2 = texture(noise2, warp_uv).r;

    // Маска огня (затухает кверху)
	float y = 1.0 - UV.y;
    float flame = n2 * (1.0 - y);

    // Формирование цвета
    vec3 color;
    color.b = smoothstep(0.2, 1.0, flame);
    color.g = smoothstep(0.1, 0.7, flame);
    color.r = smoothstep(0.0, 0.3, flame);

    // Прозрачность
    ALBEDO = color * 5.0;
    ALPHA = flame * 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
