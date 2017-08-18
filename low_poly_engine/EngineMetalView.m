//
//  EngineMetalView.m
//  low_poly_engine
//
//  Created by DEV on 8/17/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineMetalView.h"
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

typedef struct Vertex {
    vector_float4 position;
    vector_float4 color;
} Vertex;

@implementation EngineMetalView

- (void) render {
    self.device = MTLCreateSystemDefaultDevice();
    [self createBuffer];
    [self registerShaders];
    [self sendToGPU];
}

- (void) drawRect: (NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self render];
}

- (void) createBuffer {
    Vertex vertex_data[] = {{.position = {-1.0, -1.0, 0.0, 1.0}, .color = {1, 0, 0, 1}},
        {.position = { 1.0, -1.0, 0.0, 1.0}, .color = {0, 1, 0, 1}},
        {.position = { 0.0,  1.0, 0.0, 1.0}, .color = {0, 0, 1, 1}}};
    NSInteger data_size = sizeof(vertex_data) * sizeof(float);

    self.vertex_buffer = [self.device newBufferWithBytes: vertex_data length: data_size options: MTLResourceCPUCacheModeDefaultCache];
    
}

- (void) registerShaders {
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    id <MTLFunction> vertex_func = [library newFunctionWithName:@"vertex_func"];
    id <MTLFunction> frag_func = [library newFunctionWithName:@"fragment_func"];
    
    MTLRenderPipelineDescriptor *rpld = [[MTLRenderPipelineDescriptor alloc] init];
    rpld.vertexFunction = vertex_func;
    rpld.fragmentFunction = frag_func;
    rpld.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    NSError *error;
    @try {
        self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:rpld error:&error];
    } @catch (NSException *exception) {
        NSLog(@"didn't work! D:");
    } @finally {
        //NSLog(@"clean stuff up");
    }
}

- (void) sendToGPU {
    MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    if (renderPassDescriptor != nil && self.currentDrawable != nil) {
        renderPassDescriptor.colorAttachments[0].texture = self.currentDrawable.texture;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0f, 0.5f, 0.7f, 1.0f);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        NSObject <MTLCommandBuffer>*commandBuffer = self.device.newCommandQueue.commandBuffer;
        NSObject <MTLRenderCommandEncoder> *commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: renderPassDescriptor];
        
        [commandEncoder setRenderPipelineState:self.renderPipelineState];
        [commandEncoder setVertexBuffer:self.vertex_buffer offset: 0 atIndex: 0 ];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                           vertexStart: 0
                           vertexCount: 3
                         instanceCount: 1 ];
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:self.currentDrawable];
        [commandBuffer commit];
    }
}

@end
