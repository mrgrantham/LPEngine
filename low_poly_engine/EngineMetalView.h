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
#import "EnginePrimitives.h"

@interface EngineMetalView : MTKView

//@property (nonatomic, weak) NSObject <MTLCommandBuffer> *commandBuffer;
//@property (nonatomic, weak) NSObject <MTLRenderCommandEncoder> *commandEncoder;
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;
@property (nonatomic, strong) id <MTLBuffer> vertexBuffer;
@property (nonatomic, strong) EnginePrimitives *primitives;
@property (nonatomic) Vertex *vertexData;
@property (nonatomic) NSInteger vertexDataSize;
@property (nonatomic, strong) id <MTLLibrary> library;
@property (weak) IBOutlet NSTextField *lightDirectionX;
@property (weak) IBOutlet NSTextField *lightDirectionY;
@property (weak) IBOutlet NSTextField *lightDirectionZ;

- (void) render;
- (void) drawRect: (NSRect)dirtyRect;
- (void) createBuffer;
- (void) registerShaders;
- (void) sendToGPU;
- (IBAction)rotateCounterClockwise:(id)sender;
- (IBAction)rotateClockwise:(id)sender;
- (IBAction)translateLeft:(id)sender;
- (IBAction)translateRight:(id)sender;
- (IBAction)scaleSmaller:(id)sender;
- (IBAction)scaleLarger:(id)sender;
- (IBAction)rotateContinuous:(id)sender;
- (IBAction)translateContinuous:(id)sender;
- (IBAction)scaleContinuous:(id)sender;
- (IBAction)resetDemo:(id)sender;


@end

#endif /* EngineMetalView_h */
