//
//  EngineMetalView.h
//  low_poly_engine
//
//  Created by James Granthamon 8/17/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef EngineMetalView_h
#define EngineMetalView_h

//#import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "LPEnginePrimitives.h"

@interface EngineMetalView : MTKView

//@property (nonatomic, weak) NSObject <MTLCommandBuffer> *commandBuffer;
//@property (nonatomic, weak) NSObject <MTLRenderCommandEncoder> *commandEncoder;
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;
@property (nonatomic, strong) id <MTLBuffer> vertexBuffer;
@property (nonatomic, strong) LPEnginePrimitives *primitives;
@property (nonatomic) Vertex *vertexData;
@property (nonatomic) NSInteger vertexDataSize;
@property (nonatomic, strong) id <MTLLibrary> library;

- (void) render;
- (void) drawRect: (CGRect)dirtyRect;
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
- (IBAction)engageFlight:(id)sender;
@end

#endif /* EngineMetalView_h */
