#include <flutter/runtime_effect.glsl>

#define MAX_POINTS 8

uniform lowp vec2 iResolution;  // Resolution of the canvas (width, height)
uniform float numPoints;        // Number of points to process
uniform vec4 pointData[MAX_POINTS * 2];  // [pos.x, pos.y, strength, inv_2_sigma2], [color.r, color.g, color.b, color.a]

out lowp vec4 fragColor;

// Reusable function to process a single point
void processPoint(vec4 properties, vec4 color, vec2 uv, inout vec4 sumColor, inout float sumWeights) {
    vec2 pos = properties.xy;
    float strength = properties.z;
    float inv_2_sigma2 = properties.w;
    float d2 = dot(pos - uv, pos - uv); // Compute squared distance
    float weight = strength * exp(-d2 * inv_2_sigma2);

    sumColor += weight * color;
    sumWeights += weight;
}

void main() {
    // Normalize fragment coordinates to UV space [0,1]
    lowp vec2 uv = FlutterFragCoord().xy / iResolution.xy;
    
    // Initialize accumulators
    vec4 sumColor = vec4(0.0);
    float sumWeights = 0.0;
    
    // Call the reusable function for each point, up to numPoints
    if (0 < numPoints) processPoint(pointData[0], pointData[1], uv, sumColor, sumWeights);
    if (1 < numPoints) processPoint(pointData[2], pointData[3], uv, sumColor, sumWeights);
    if (2 < numPoints) processPoint(pointData[4], pointData[5], uv, sumColor, sumWeights);
    if (3 < numPoints) processPoint(pointData[6], pointData[7], uv, sumColor, sumWeights);
    if (4 < numPoints) processPoint(pointData[8], pointData[9], uv, sumColor, sumWeights);
    if (5 < numPoints) processPoint(pointData[10], pointData[11], uv, sumColor, sumWeights);
    if (6 < numPoints) processPoint(pointData[12], pointData[13], uv, sumColor, sumWeights);
    if (7 < numPoints) processPoint(pointData[14], pointData[15], uv, sumColor, sumWeights);
    
    // Normalize and output the final color
    fragColor = (sumWeights > 0.0) ? (sumColor / sumWeights) : vec4(0.0);
}