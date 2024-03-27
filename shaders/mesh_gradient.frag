// Credits to [https://johnflux.com/2016/03/16/four-point-gradient-as-a-shader] for sharing the original shader code.

#version 460 core

#include <flutter/runtime_effect.glsl>

#define epsilon 0.0001

uniform lowp vec2 uSize;

uniform lowp vec3 color0;
uniform lowp vec3 color1;
uniform lowp vec3 color2;
uniform lowp vec3 color3;

// coordinates relative to center, not topLeft
uniform lowp vec2 p0;
uniform lowp vec2 p1;
uniform lowp vec2 p2;
uniform lowp vec2 p3;

uniform lowp vec4 s2;

uniform lowp vec2 w0;
uniform lowp vec2 w1;
uniform lowp vec2 w2;
uniform lowp vec2 w3;

out vec4 fragColor;

vec4 grad(vec2 uv) {

    // color samples coordinates
    vec2 P0 = vec2(0.1,0.1);
    vec2 P1 = vec2(0.9,0.1);
    vec2 P2 = vec2(0.1,0.9);
    vec2 P3 = vec2(0.9,0.9);
 
    vec2 Q = P0 - P2;
    vec2 R = P1 - P0;
    vec2 S = R + P2 - P3;
    vec2 T = P0 - uv;
 
    float u;
    float t;
 
    if(Q.x == 0.0 && S.x == 0.0) {
        u = -T.x/R.x;
        t = (T.y + u*R.y) / (Q.y + u*S.y);
    } else if(Q.y == 0.0 && S.y == 0.0) {
        u = -T.y/(R.y + epsilon); // SKSL doesn't support division by zero
        t = (T.x + u*R.x) / ((Q.x + u*S.x) + epsilon); // SKSL division
    } else {
        float A = S.x * R.y - R.x * S.y;
        float B = S.x * T.y - T.x * S.y + Q.x*R.y - R.x*Q.y;
        float C = Q.x * T.y - T.x * Q.y;
        if(abs(A) < epsilon)
            u = -C/B;
        else
        u = (-B+sqrt(B*B-4.0*A*C))/(2.0*(A+ epsilon)); // SKSL division
        t = (T.y + u*R.y) / (Q.y + u*S.y);
    }
    u = clamp(u,0.0,1.0);
    t = clamp(t,0.0,1.0);
 

    t = smoothstep(0.0, 1.0, t);
    u = smoothstep(0.0, 1.0, u);
 
    vec4 colorA = mix(vec4(color0, 1.0), vec4(color2, 1.0),u);
    vec4 colorB = mix(vec4(color1, 1.0), vec4(color3, 1.0),u);
    
    return mix(colorA, colorB, t);
}

void main() {
    lowp vec2 uv = FlutterFragCoord().xy / uSize.xy;

    vec2 p = uv * 2.0 - 1.0;
    vec2 q = vec2(0, 0);

    vec2 delta;
    float distsq;
    float H_i;

    // Point 0
    delta = p - p0;
    distsq = dot(delta, delta);
    H_i = sqrt(distsq + s2.x);
    q += H_i * w0;

    // Point 1
    delta = p - p1;
    distsq = dot(delta, delta);
    H_i = sqrt(distsq + s2.y);
    q += H_i * w1;

    // Point 2
    delta = p - p2;
    distsq = dot(delta, delta);
    H_i = sqrt(distsq + s2.z);
    q += H_i * w2;

    // Point 3
    delta = p - p3;
    distsq = dot(delta, delta);
    H_i = sqrt(distsq + s2.w);
    q += H_i * w3;
        
    fragColor = grad((q + 1.0) / 2.0);
}
