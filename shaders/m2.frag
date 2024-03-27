// Credits to [https://johnflux.com/2016/03/16/four-point-gradient-as-a-shader] for sharing the original shader code.

#version 460 core

#include <flutter/runtime_effect.glsl>

#define MAX_POINTS 4

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

    // coordinates
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
        u = -T.y/R.y;
        t = (T.x + u*R.x) / (Q.x + u*S.x);
    } else {
        float A = S.x * R.y - R.x * S.y;
        float B = S.x * T.y - T.x * S.y + Q.x*R.y - R.x*Q.y;
        float C = Q.x * T.y - T.x * Q.y;
        if(abs(A) < 0.0001)
            u = -C/B;
        else
        u = (-B+sqrt(B*B-4.0*A*C))/(2.0*A);
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
    int npoints = 4; // number of points passed, 4 for now always

    float s2Arr[MAX_POINTS] = float[4](s2.x, s2.y, s2.z, s2.w);
    vec2 points[MAX_POINTS] = vec2[4](p0, p1, p2, p3);
    vec2 w[MAX_POINTS] = vec2[4](w0, w1, w2, w3);

    vec2 p = uv * 2.0 - 1.0;
    vec2 q = vec2(0, 0);

    for (int i = 0; i < MAX_POINTS; i++) {
        if (i >= npoints)
        continue;
        vec2 points_i = points[i];
        float s2_i = s2Arr[i];
        vec2 w_i = w[i];
        vec2 delta = p - points_i;
        float distsq = dot(delta, delta);
        float H_i = sqrt(distsq + s2_i);
        q += H_i * w_i;
    }
        
    fragColor = grad((q + 1.0) / 2.0);
}
