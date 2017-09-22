//
//  engineShaders.metal
//  low_poly_engine
//
//  Created by James Granthamon 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Vertex {
    float4 position [[position]];
    float4 color;
    float pointsize[[point_size]];
};

//struct VertexOut{
//    float pointsize[[point_size]];
//};
//
//const VertexOut.pointsize = 10.0;

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
//    return {1.0, 0.0, 0.0, 1.0};
    return vert.color;
}
