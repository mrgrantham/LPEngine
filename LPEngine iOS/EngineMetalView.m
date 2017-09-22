//
//  EngineMetalView.m
//  low_poly_engine
//
//  Created by James Granthamon 8/17/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineMetalView.h"
//#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "LPEnginePrimitives.h"
#import "LPEngineDemos.h"


@implementation EngineMetalView {
    CGPoint _lastDragLocation;
}

- (id) init {
    self = [super init];
    self.primitives = [LPEnginePrimitives sharedManager];
    self.vertexData = nil;
    self.vertexDataSize = 0;

    
    return self;
}

- (id) initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])){
        self.primitives = [LPEnginePrimitives sharedManager];
        self.vertexData = nil;
        self.vertexDataSize = 0;
        
        self.preferredFramesPerSecond = 60;
        CGRect appFrame = [[UIScreen mainScreen] bounds];
        [self.primitives setPixelWidth:1];
        [self.primitives setVirtualWidth:appFrame.size.width];
        [self.primitives setVirtualHeight:appFrame.size.height];
        [self.primitives resetDepthBuffer];
        [self.primitives centerCamera];
        
        CGSize canvasSize = [self.primitives canvasSize];
        if (!CGSizeEqualToSize(self.window.frame.size,canvasSize)) {
            CGRect frame = [self.window frame];
            frame.size = canvasSize;
//            frame.origin = CGPointMake(50, 50);
            NSLog(@"window frame render %@",NSStringFromCGRect(frame) );
//            [self.window setFrame:frame display:YES animate:YES];
        }
        self.device = MTLCreateSystemDefaultDevice();
        NSLog(@"\nDevice: %@ \nDescription: %@ \n maxThreadsPerThreadgroup: width %li height %li depth %li ",self.device.name,self.device.description, (unsigned long)self.device.maxThreadsPerThreadgroup.width,self.device.maxThreadsPerThreadgroup.height,(unsigned long)self.device.maxThreadsPerThreadgroup.depth);
        self.library = [self.device newDefaultLibrary];
        [self registerShaders];
        
        MTLRenderPassDescriptor *renderPassDescriptor = self.currentRenderPassDescriptor;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2f, 0.2f, 0.8f, 1.0f);
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        

        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handleGestureRecognizer:)];
        [self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

static CGPoint CGPointDelta(CGPoint p1, CGPoint p2) {
    return CGPointMake(p2.x - p1.x, p2.y - p1.y);
}

- (void)handleGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    switch ([panGestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
        {
            // Halt other demos
            demo.flyContinuous = NO;
            demo.rotateContinuous = NO;
            demo.translateContinuous = NO;
            demo.scaleContinuous = NO;
            
            _lastDragLocation = [panGestureRecognizer locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [panGestureRecognizer locationInView:self];
            CGPoint delta = CGPointDelta(location, _lastDragLocation);
            _lastDragLocation = location;
            [demo applyRotation:LPPointMake(delta.x, delta.y, 0.0)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
        }
            break;
        default:
            break;
    }
}

- (void) render {
//    self.device = MTLCreateSystemDefaultDevice();
    [self createBuffer];
    [self sendToGPU];
    
    CGSize canvasSize = [self.primitives canvasSize];
    if (!CGSizeEqualToSize(self.window.frame.size,canvasSize)) {
        CGRect frame = [self.window frame];
        frame.size = canvasSize;
        NSLog(@"window frame render %@",NSStringFromCGRect(frame) );
//        [self.window setFrame:frame display:YES animate:YES];
    }

}

- (void) drawRect: (CGRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self render];
}

- (void) createBuffer {
    

    [self.primitives clearVertices];

    [self.primitives setColorWithRed:200 Green:200 Blue:200];

//    [[EngineDemos sharedManager] triangleDemo];
    [[LPEngineDemos sharedManager] arwingDemo];
    
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
//    self.vertexBuffer = [self.device newBufferWithBytesNoCopy: self.vertexData length: self.vertexDataSize * sizeof(Vertex) options: MTLResourceCPUCacheModeDefaultCache deallocator:^(void * _Nonnull pointer, NSUInteger length) {
    
//    }];

}

- (void) registerShaders {
//    id <MTLLibrary> library = [self.device newDefaultLibrary];
    
    id <MTLFunction> vertex_func = [self.library newFunctionWithName:@"vertex_func"];
    id <MTLFunction> frag_func = [self.library newFunctionWithName:@"fragment_func"];
    
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
//    MTLRenderPassDescriptor *renderPassDescriptor = [[MTLRenderPassDescriptor alloc] init];
    MTLRenderPassDescriptor *renderPassDescriptor = self.currentRenderPassDescriptor;

    if (renderPassDescriptor != nil && self.currentDrawable != nil) {
//        renderPassDescriptor.colorAttachments[0].texture = self.currentDrawable.texture;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.2f, 0.2f, 0.8f, 1.0f);
//        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
        NSObject <MTLCommandBuffer>*commandBuffer = self.device.newCommandQueue.commandBuffer;
        NSObject <MTLRenderCommandEncoder> *commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: renderPassDescriptor];
        
        [commandEncoder setRenderPipelineState:self.renderPipelineState];
        [commandEncoder setVertexBuffer:self.vertexBuffer offset: 0 atIndex: 0 ];
        if (self.vertexDataSize != 0) {

            [commandEncoder drawPrimitives:MTLPrimitiveTypePoint
                               vertexStart: 0
                               vertexCount: self.vertexDataSize
                             instanceCount: 1 ];
        }
        [commandEncoder endEncoding];
        [commandBuffer presentDrawable:self.currentDrawable];
        [commandBuffer commit];
    }
}

- (IBAction)rotateCounterClockwise:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.rotateContinuous = NO;
    NSLog(@"counterclockwise!!!");
    LPPoint rotationVector = {};
    rotationVector.y = 0.05;
    [demo.demoScene.models[demo.arwingID].model rotateWithVector:rotationVector];
}

- (IBAction)rotateClockwise:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.rotateContinuous = NO;
    NSLog(@"clockwise!!!");
    LPPoint rotationVector = {};
    rotationVector.y = -0.05;
    [demo.demoScene.models[demo.arwingID].model rotateWithVector:rotationVector];
}

- (IBAction)translateLeft:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.translateContinuous = NO;
    NSLog(@"translate left");
    LPPoint rotationVector = {};
    rotationVector.x = -5;
    [demo.demoScene.models[demo.arwingID].model translateWithVector:rotationVector];
}

- (IBAction)translateRight:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.translateContinuous = NO;
    NSLog(@"translate right");
    LPPoint translationVector = {};
    translationVector.x = 5;
    [demo.demoScene.models[demo.arwingID].model translateWithVector:translationVector];
}

- (IBAction)scaleSmaller:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.scaleContinuous = NO;
    NSLog(@"scale smaller");
    LPPoint scaleVector = {};
    scaleVector.x =  -0.05;
    scaleVector.y =  -0.05;
    scaleVector.z =  -0.05;
    [demo.demoScene.models[demo.arwingID].model scaleWithVector:scaleVector];
}

- (IBAction)scaleLarger:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    demo.scaleContinuous = NO;
    NSLog(@"scale larger");
    LPPoint scaleVector = {};
    scaleVector.x =  0.05;
    scaleVector.y =  0.05;
    scaleVector.z =  0.05;
    [demo.demoScene.models[demo.arwingID].model scaleWithVector:scaleVector];
}

- (IBAction)rotateContinuous:(id)sender {
    NSLog(@"Activating continuous rotation mode");
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    if (demo.rotateContinuous) {
        demo.rotateContinuous = NO;
    } else {
        demo.rotateContinuous = YES;
    }
}

- (IBAction)translateContinuous:(id)sender {
    NSLog(@"Activating continuous translation mode");
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    if (demo.translateContinuous) {
        demo.translateContinuous = NO;
    } else {
        demo.translateContinuous = YES;
    }
}

- (IBAction)scaleContinuous:(id)sender {
    NSLog(@"Activation continuous scaling mode");
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    if (demo.scaleContinuous) {
        demo.scaleContinuous = NO;
    } else {
        demo.scaleContinuous = YES;
    }
}

- (IBAction)resetDemo:(id)sender {
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    [demo resetArwing];
}

- (IBAction)engageFlight:(id)sender {
    NSLog(@"WHEEEE IM FLYING!!!");
    LPPoint rotateVector = {};
    rotateVector.y = 3*M_PI/4;
    LPEngineDemos *demo = [LPEngineDemos sharedManager];
    [demo resetArwing];
    [demo resetFlight];
    [demo.demoScene.models[demo.arwingID].model rotateWithVector:rotateVector];
    
    if (demo.flyContinuous) {
        demo.flyContinuous = NO;
    } else {
        demo.flyContinuous = YES;
    }
}

@end
