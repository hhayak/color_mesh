#include <flutter/runtime_effect.glsl>

#define MAX_POINTS 8

uniform lowp vec2 iResolution;       // Resolution of the canvas (width, height)
uniform float numPoints;          // Number of points to process
uniform vec2 positions[MAX_POINTS];     // Array of 2D positions (x, y) in UV space [0,1]
uniform lowp vec4 colors[MAX_POINTS];        // Array of colors (r, g, b, a) for each point
uniform float strengths[MAX_POINTS];    // Array of weights (influence strength) for each point
uniform lowp float sigmas[MAX_POINTS];       // Array of sigmas (spread) for Gaussian weighting

out lowp vec4 fragColor;

void main() {
    // Normalize fragment coordinates to UV space [0,1]
    lowp vec2 uv = FlutterFragCoord().xy / iResolution.xy;
    
    // Initialize accumulators for color and weights
    vec4 sumColor = vec4(0.0);
    float sumWeights = 0.0;
    
    // Loop over each point up to numPoints
    for (int i = 0; i < MAX_POINTS; i++) {
        if (i >= numPoints) {break;}
        vec2 pos = positions[i];      // Position of the current point
        vec4 col = colors[i];         // Color of the current point
        float strength = strengths[i]; // Weight of the current point
        float sigma = sigmas[i];      // Spread of the Gaussian for the current point
        
        // Calculate distance from the fragment to the point
        float d = length(pos - uv);
        // Compute Gaussian weight based on distance and sigma
        float weight = strength * exp(- (d * d) / (2.0 * sigma * sigma));
        
        // Accumulate weighted color and total weight
        sumColor += weight * col;
        sumWeights += weight;
    }
    
    // Normalize the color by the sum of weights and set the output
    fragColor = sumColor / sumWeights;
}