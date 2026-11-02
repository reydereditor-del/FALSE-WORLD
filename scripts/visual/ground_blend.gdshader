shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D albedo_map : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_map : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D roughness_map : filter_linear_mipmap, repeat_enable;
varying vec3 world_point;
void vertex() {
    world_point = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
    vec2 uv = world_point.xz * 0.3;
    vec2 edge = vec2(16.0) - abs(world_point.xz - vec2(200.0, 126.0));
    float blend = smoothstep(0.0, 2.5, min(edge.x, edge.y));
    ALBEDO = mix(vec3(0.4118, 0.4510, 0.3569), texture(albedo_map, uv).rgb, blend);
    NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), texture(normal_map, uv).rgb, blend);
    NORMAL_MAP_DEPTH = 0.25;
    ROUGHNESS = mix(1.0, texture(roughness_map, uv).r, blend);
}
