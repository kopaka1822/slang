#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_NV_ray_tracing_motion_blur : require
layout(row_major) uniform;
layout(row_major) buffer;

#line 5 "tests/nv-extensions/nv-ray-tracing-motion-blur.slang"
layout(binding = 0)
uniform texture2D samplerPosition_0;


#line 7
layout(binding = 2)
uniform sampler sampler_0;


#line 6
layout(binding = 1)
uniform texture2D samplerNormal_0;

struct Light_0
{
    vec4 position_0;
    vec4 color_0;
};


#line 14
struct Uniforms_0
{
    Light_0 light_0;
    vec4 viewPos_0;
    mat4x4 view_0;
    mat4x4 model_0;
};


#line 21
layout(binding = 3)
layout(std140) uniform _S1
{
    Light_0 light_0;
    vec4 viewPos_0;
    mat4x4 view_0;
    mat4x4 model_0;
}ubo_0;

#line 26
layout(binding = 5)
uniform accelerationStructureEXT as_0;


#line 24
layout(rgba32f)
layout(binding = 4)
uniform image2D outputImage_0;


#line 33
struct ReflectionRay_0
{
    float color_1;
};


#line 5218 "hlsl.meta.slang"
layout(location = 0)
rayPayloadEXT
ReflectionRay_0 p_0;


#line 28 "tests/nv-extensions/nv-ray-tracing-motion-blur.slang"
struct ShadowRay_0
{
    float hitDistance_0;
};


#line 5286 "hlsl.meta.slang"
layout(location = 1)
rayPayloadEXT
ShadowRay_0 p_1;


#line 5079
struct RayDesc_0
{
    vec3 Origin_0;
    float TMin_0;
    vec3 Direction_0;
    float TMax_0;
};


#line 5243
void TraceMotionRay_0(accelerationStructureEXT AccelerationStructure_0, uint RayFlags_0, uint InstanceInclusionMask_0, uint RayContributionToHitGroupIndex_0, uint MultiplierForGeometryContributionToHitGroupIndex_0, uint MissShaderIndex_0, RayDesc_0 Ray_0, float CurrentTime_0, inout ShadowRay_0 Payload_0)
{

#line 5288
    p_1 = Payload_0;
    traceRayMotionNV(AccelerationStructure_0, RayFlags_0, InstanceInclusionMask_0, RayContributionToHitGroupIndex_0, MultiplierForGeometryContributionToHitGroupIndex_0, MissShaderIndex_0, Ray_0.Origin_0, Ray_0.TMin_0, Ray_0.Direction_0, Ray_0.TMax_0, CurrentTime_0, (1));

#line 5302
    Payload_0 = p_1;
    return;
}


#line 3527
float saturate_0(float x_0)
{
    return clamp(x_0, 0.0, 1.0);
}


#line 5168
void TraceRay_0(accelerationStructureEXT AccelerationStructure_1, uint RayFlags_1, uint InstanceInclusionMask_1, uint RayContributionToHitGroupIndex_1, uint MultiplierForGeometryContributionToHitGroupIndex_1, uint MissShaderIndex_1, RayDesc_0 Ray_1, inout ReflectionRay_0 Payload_1)
{

#line 5220
    p_0 = Payload_1;
    traceRayEXT(AccelerationStructure_1, RayFlags_1, InstanceInclusionMask_1, RayContributionToHitGroupIndex_1, MultiplierForGeometryContributionToHitGroupIndex_1, MissShaderIndex_1, Ray_1.Origin_0, Ray_1.TMin_0, Ray_1.Direction_0, Ray_1.TMax_0, (0));

#line 5233
    Payload_1 = p_0;
    return;
}


#line 38 "tests/nv-extensions/nv-ray-tracing-motion-blur.slang"
void main()
{
    uvec3 _S2 = ((gl_LaunchIDEXT));

#line 40
    ivec2 launchID_0 = ivec2(_S2.xy);
    uvec3 _S3 = ((gl_LaunchSizeEXT));

#line 41
    ivec2 launchSize_0 = ivec2(_S3.xy);

    vec2 inUV_0 = vec2((float(launchID_0.x) + 0.5) / float(launchSize_0.x), (float(launchID_0.y) + 0.5) / float(launchSize_0.y));

#line 48
    vec4 _S4 = (texture(sampler2D(samplerPosition_0,sampler_0), (inUV_0)));

#line 48
    vec3 P_0 = _S4.xyz;
    vec4 _S5 = (texture(sampler2D(samplerNormal_0,sampler_0), (inUV_0)));

#line 49
    vec3 N_0 = _S5.xyz * 2.0 - 1.0;


    vec3 lightDelta_0 = ubo_0.light_0.position_0.xyz - P_0;
    float lightDist_0 = length(lightDelta_0);
    vec3 L_0 = normalize(lightDelta_0);
    float _S6 = 1.0 / (lightDist_0 * lightDist_0);

    RayDesc_0 ray_0;
    ray_0.Origin_0 = P_0;
    ray_0.TMin_0 = 0.00000099999999747524;
    ray_0.Direction_0 = lightDelta_0;
    ray_0.TMax_0 = lightDist_0;


    ShadowRay_0 shadowRay_0;
    shadowRay_0.hitDistance_0 = 0.0;



    TraceMotionRay_0(as_0, 1U, 255U, 0U, 0U, 2U, ray_0, 1.0, shadowRay_0);

#line 69
    float atten_0;

#line 87
    if(shadowRay_0.hitDistance_0 < lightDist_0)
    {

#line 87
        atten_0 = 0.0;

#line 87
    }
    else
    {

#line 87
        atten_0 = _S6;

#line 87
    }

#line 93
    vec3 color_2 = ubo_0.light_0.color_0.xyz * saturate_0(dot(N_0, L_0)) * atten_0;


    ReflectionRay_0 reflectionRay_0;
    TraceRay_0(as_0, 1U, 255U, 0U, 0U, 2U, ray_0, reflectionRay_0);

#line 117
    imageStore((outputImage_0), ivec2((uvec2(launchID_0))), vec4(color_2 + reflectionRay_0.color_1, 1.0));
    return;
}

