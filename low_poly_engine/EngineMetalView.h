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

- (void) render;
- (void) drawRect: (NSRect)dirtyRect;


@end

#endif /* EngineMetalView_h */
