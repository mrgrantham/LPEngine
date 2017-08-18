//
//  EngineMetalView.h
//  low_poly_engine
//
//  Created by DEV on 8/17/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineMetalView_h
#define EngineMetalView_h

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface EngineMetalView : MTKView

//@property (nonatomic, weak) NSObject <MTLCommandBuffer> *commandBuffer;
//@property (nonatomic, weak) NSObject <MTLRenderCommandEncoder> *commandEncoder;
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;
@property (nonatomic, strong) id <MTLBuffer> vertex_buffer;
- (void) render;
- (void) drawRect: (NSRect)dirtyRect;
- (void) createBuffer;
- (void) registerShaders;
- (void) sendToGPU;


@end

#endif /* EngineMetalView_h */
