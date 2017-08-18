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

@implementation EngineMetalView

- (void) render {
    NSObject <MTLDevice> *defaultDev = MTLCreateSystemDefaultDevice();
    self.device = defaultDev;
    
    MTLRenderPassDescriptor *rpd = [[MTLRenderPassDescriptor alloc] init];
    
    MTLClearColor bleen = {.red = 0.0f, .green = 0.5f, .blue = 0.5f, .alpha = 0.0f};
    
    rpd.colorAttachments[0].texture = self.currentDrawable.texture;
    rpd.colorAttachments[0].clearColor = bleen;
    rpd.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    NSObject <MTLCommandQueue> *commandQueue = self.device.newCommandQueue;
    NSObject <MTLCommandBuffer>*commandBuffer = commandQueue.commandBuffer;
    NSObject <MTLRenderCommandEncoder> *encoder = [commandBuffer renderCommandEncoderWithDescriptor: rpd];
    [encoder endEncoding];
    [commandBuffer presentDrawable:self.currentDrawable];
     [commandBuffer commit];
    
}

- (void) drawRect: (NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self render];
}

@end
