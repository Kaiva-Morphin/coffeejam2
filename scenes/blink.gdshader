shader_type canvas_item;

uniform float radius:    hint_range(0.0, 1.0) = 0.15;  
uniform float softness:  hint_range(0.0, 1.0) = 0.1;  
uniform float intensity: hint_range(0.0, 3.0) = 2.0;  
uniform float contrast:  hint_range(0.5, 4.0) = 2.0;  
uniform vec4 vignette_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Глобальные координаты моргания глаз
uniform float blink_left:  hint_range(0.0, 1.0) = 0.0;  // 0 = глаза открыты, 1 = глаза закрыты
uniform float blink_right: hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Координаты глаз по X (левый и правый)
    vec2 left_eye_center = vec2(0.35, 0.5);
    vec2 right_eye_center = vec2(0.65, 0.5);

    // Вычисляем расстояние до центра каждого глаза
    float dist_left  = length(uv - left_eye_center);
    float dist_right = length(uv - right_eye_center);

    // Эффект затемнения глаз с учётом моргания
    float v_left  = smoothstep(radius, radius + softness, dist_left - blink_left * radius);
    float v_right = smoothstep(radius, radius + softness, dist_right - blink_right * radius);

    // Контраст и интенсивность
    v_left  = pow(v_left, contrast)  * intensity;
    v_right = pow(v_right, contrast) * intensity;

    vec4 overlay = vignette_color;
    overlay.a = clamp(max(v_left, v_right), 0.0, 1.0);

    COLOR = overlay;
}