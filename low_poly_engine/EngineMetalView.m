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
        
        self.preferredFramesPerSecond = 60;
        
        [self.primitives setPixelWidth:2];
        [self.primitives setVirtualWidth:640];
        [self.primitives setVirtualHeight:480];
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

    [self.primitives setColorWithRed:200 Green:200 Blue:200];

//    [[EngineDemos sharedManager] triangleDemo];
    [[EngineDemos sharedManager] arwingDemo];
    
    self.vertexData = self.primitives.vertexData;
    self.vertexDataSize = self.primitives.vertexDataSize;
//    NSLog(@"Number of Vertexes: %i",self.vertexDataSize);
    
    if (self.vertexData == nil) {
        NSLog(@"Error: No Vertex Data");
        exit(EXIT_FAILURE);
    }
//    else {
//        float *vectors = (float *)self.vertexData;
//        for (int i = 0; i < self.vertexDataSize; i++) {
//            NSLog(@"V %d { %0.3f,%0.3f,%0.3f,%0.3f} {%0.3f,%0.3f,%0.3f,%0.3f}",i,vectors[(i*8)+0],vectors[(i*8)+1],vectors[(i*8)+2],vectors[(i*8)+3],vectors[(i*8)+4],vectors[(i*8)+5],vectors[(i*8)+6],vectors[(i*8)+7]);
//        }
//    }
//    
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
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2f, 0.2f, 0.8f, 1.0f);
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

- (IBAction)rotateCounterClockwise:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.rotateContinuous = NO;
    NSLog(@"counterclockwise!!!");
    LPPoint rotationVector = {};
    rotationVector.y = 0.05;
    [[[EngineDemos sharedManager] arwing] rotateWithVector:rotationVector];
}

- (IBAction)rotateClockwise:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.rotateContinuous = NO;
    NSLog(@"clockwise!!!");
    LPPoint rotationVector = {};
    rotationVector.y = -0.05;
    [[[EngineDemos sharedManager] arwing] rotateWithVector:rotationVector];
}

- (IBAction)translateLeft:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.translateContinuous = NO;
    NSLog(@"translate left");
    LPPoint rotationVector = {};
    rotationVector.x = -5;
    [[[EngineDemos sharedManager] arwing] translateWithVector:rotationVector];
}

- (IBAction)translateRight:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.translateContinuous = NO;
    NSLog(@"translate right");
    LPPoint translationVector = {};
    translationVector.x = 5;
    [[[EngineDemos sharedManager] arwing] translateWithVector:translationVector];
}

- (IBAction)scaleSmaller:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.scaleContinuous = NO;
    NSLog(@"scale smaller");
    LPPoint scaleVector = {};
    scaleVector.x =  -0.05;
    scaleVector.y =  -0.05;
    scaleVector.z =  -0.05;
    [[[EngineDemos sharedManager] arwing] scaleWithVector:scaleVector];
}

- (IBAction)scaleLarger:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    demo.scaleContinuous = NO;
    NSLog(@"scale larger");
    LPPoint scaleVector = {};
    scaleVector.x =  0.05;
    scaleVector.y =  0.05;
    scaleVector.z =  0.05;
    [[[EngineDemos sharedManager] arwing] scaleWithVector:scaleVector];
}

- (IBAction)rotateContinuous:(id)sender {
    NSLog(@"Activating continuous rotation mode");
    EngineDemos *demo = [EngineDemos sharedManager];
    if (demo.rotateContinuous) {
        demo.rotateContinuous = NO;
    } else {
        demo.rotateContinuous = YES;
    }
}

- (IBAction)translateContinuous:(id)sender {
    NSLog(@"Activating continuous translation mode");
    EngineDemos *demo = [EngineDemos sharedManager];
    if (demo.translateContinuous) {
        demo.translateContinuous = NO;
    } else {
        demo.translateContinuous = YES;
    }
}

- (IBAction)scaleContinuous:(id)sender {
    NSLog(@"Activation continuous scaling mode");
    EngineDemos *demo = [EngineDemos sharedManager];
    if (demo.scaleContinuous) {
        demo.scaleContinuous = NO;
    } else {
        demo.scaleContinuous = YES;
    }
}

- (IBAction)resetDemo:(id)sender {
    EngineDemos *demo = [EngineDemos sharedManager];
    [demo resetArwing];
}

@end
