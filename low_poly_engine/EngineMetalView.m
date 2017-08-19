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
#import "EnginePrimitives.h"
#import "EngineDemos.h"


@implementation EngineMetalView

- (id) init {
    self = [super init];
    self.primitives = [EnginePrimitives sharedManager];
    self.vertexData = nil;
    self.vertexDataSize = 0;

    
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])){
        self.primitives = [EnginePrimitives sharedManager];
        self.vertexData = nil;
        self.vertexDataSize = 0;
        
        
        [self.primitives setPixelWidth:4];
        [self.primitives setVirtualWidth:320];
        [self.primitives setVirtualHeight:240];
        [self.primitives resetDepthBuffer];
        
        CGSize canvasSize = [self.primitives canvasSize];
        if (!CGSizeEqualToSize(self.window.frame.size,canvasSize)) {
            NSRect frame = [self.window frame];
            frame.size = canvasSize;
            NSLog(@"window frame render %@",NSStringFromRect(frame) );
            [self.window setFrame:frame display:YES animate:YES];
        }

    }
    return self;
}

- (void) render {
    self.device = MTLCreateSystemDefaultDevice();
    [self createBuffer];
    [self registerShaders];
    [self sendToGPU];
    
    CGSize canvasSize = [self.primitives canvasSize];
    if (!CGSizeEqualToSize(self.window.frame.size,canvasSize)) {
        NSRect frame = [self.window frame];
        frame.size = canvasSize;
        NSLog(@"window frame render %@",NSStringFromRect(frame) );
        [self.window setFrame:frame display:YES animate:YES];
    }

}

- (void) drawRect: (NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self render];
}

- (void) createBuffer {
    

    [self.primitives clearVertices];
//    [self.primitives setColorWithRed:20 Green:200 Blue:0];
//    [self.primitives drawPixelAtX:3 Y:3];
//    [self.primitives drawPixelAtX:0 Y:0];
//    [self.primitives setColorWithRed:200 Green:200 Blue:0];
//    [self.primitives drawPixelAtX:10 Y:20];
//    [self.primitives drawPixelAtX:20 Y:20];
//    [self.primitives setColorWithRed:0 Green:200 Blue:0];
//    [self.primitives drawPixelAtX:9 Y:10];
//    [self.primitives drawPixelAtX:10 Y:9];
//    [self.primitives drawPixelAtX:11 Y:9];
//    [self.primitives drawPixelAtX:12 Y:8];
//    [self.primitives drawPixelAtX:13 Y:8];
//    [self.primitives drawPixelAtX:14 Y:8];
//    [self.primitives drawPixelAtX:15 Y:8];
//    [self.primitives drawPixelAtX:16 Y:8];
//    [self.primitives drawPixelAtX:17 Y:8];
//    [self.primitives drawPixelAtX:18 Y:8];
//    [self.primitives drawPixelAtX:19 Y:9];
//    [self.primitives drawPixelAtX:20 Y:9];
//    [self.primitives drawPixelAtX:21 Y:10];

    [self.primitives setColorWithRed:200 Green:200 Blue:0];
//    [self.primitives drawTriangleAtCopiedPoint1:LPPointMake(10, 10, 0) Point2:LPPointMake(20, 20, 0) Point3:LPPointMake(15, 25, 0)];
    [EngineDemos triangleDemo];
    
    self.vertexData = self.primitives.vertexData;
    self.vertexDataSize = self.primitives.vertexDataSize;
//    NSLog(@"Number of Vertexes: %i",self.vertexDataSize);
    
    if (self.vertexData == nil) {
        NSLog(@"Error with vertex data");
    } else {
        float *vectors = (float *)self.vertexData;
//        for (int i = 0; i < self.vertexDataSize; i++) {
//            NSLog(@"V %d { %0.3f,%0.3f,%0.3f,%0.3f} {%0.3f,%0.3f,%0.3f,%0.3f}",i,vectors[(i*8)+0],vectors[(i*8)+1],vectors[(i*8)+2],vectors[(i*8)+3],vectors[(i*8)+4],vectors[(i*8)+5],vectors[(i*8)+6],vectors[(i*8)+7]);
//        }
    }
    
    self.vertexBuffer = [self.device newBufferWithBytes: self.vertexData length: self.vertexDataSize * sizeof(Vertex) options: MTLResourceCPUCacheModeDefaultCache];
    
}

- (void) registerShaders {
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    id <MTLFunction> vertex_func = [library newFunctionWithName:@"vertex_func"];
    id <MTLFunction> frag_func = [library newFunctionWithName:@"fragment_func"];
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.vertexFunction = vertex_func;
    renderPipelineDescriptor.fragmentFunction = frag_func;
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    NSError *error;
    @try {
        self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:&error];
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
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0f, 0.2f, 0.2f, 1.0f);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        NSObject <MTLCommandBuffer>*commandBuffer = self.device.newCommandQueue.commandBuffer;
        NSObject <MTLRenderCommandEncoder> *commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: renderPassDescriptor];
        
        [commandEncoder setRenderPipelineState:self.renderPipelineState];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset: 0 atIndex: 0 ];
        [commandEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                           vertexStart: 0
                           vertexCount: self.vertexDataSize
                         instanceCount: 1 ];
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:self.currentDrawable];
        [commandBuffer commit];
    }
}

@end
