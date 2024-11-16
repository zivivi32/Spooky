shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float emission_amount : hint_range(0.0, 5.0) = 0.5;
uniform vec4 emission_color : source_color;
uniform float deformation_scale : hint_range(0.0, 15.0) = 1.0;
uniform float deformation_speed : hint_range(0.0, 15.0) = 2.0;
uniform float deformation_amplitude : hint_range(0.0, 15.0) = 0.1;

// Instance-specific parameters
varying float instance_offset;

void vertex() {
    // Generate a unique offset based on the instance ID
    instance_offset = float(INSTANCE_ID) * 1234.5678;

    vec3 vertex_position = VERTEX;

    // Apply jelly-like deformation with multiple waves
    float time = TIME * deformation_speed;

    // Primary wave
    float deformation = sin(time + instance_offset + vertex_position.x * (deformation_scale/100.0)) * deformation_amplitude;

    // Secondary wave (different frequency and phase)
    deformation += cos(time * 0.7 + instance_offset * 2.0 + vertex_position.z * deformation_scale) * (deformation_amplitude * 0.5);

    // Add some radial variation
    float radial = length(vertex_position.xz);
    deformation *= smoothstep(0.0, 1.0, radial * 0.5);

    vertex_position.y += deformation;

    VERTEX = vertex_position;

    // Update normals to match the deformation
    vec3 normal_offset = vec3(
        deformation * cos(time + vertex_position.x),
        1.0,
        deformation * sin(time + vertex_position.z)
    );
    NORMAL = normalize(NORMAL + normal_offset * deformation_scale);
}

void fragment() {
    vec2 base_uv = UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);

    // Add some color variation based on deformation
    vec3 final_color = albedo.rgb * albedo_tex.rgb;

    // Optional: Add slight color variation based on instance
    float color_variation = sin(instance_offset * 0.1) * 0.1 + 1.0;
    final_color *= vec3(color_variation);

    ALBEDO = final_color;
	ALPHA = albedo.a;
    EMISSION = emission_color.rgb * emission_amount;
}