//
//  EngineDemos.m
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnginePrimitives.h"
#import "EngineTransforms.h"
#import "EngineDemos.h"

@implementation EngineDemos

+ (void) triangleDemo {
    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    
    static LPPoint _2Daxis;
    static float currentRadian = 0.0;
    static LPTriangle testTriangle;
    testTriangle = LPTriangleMake(LPPointMake(100,100,0), LPPointMake(170,130,0), LPPointMake(180,200,0));
    _2Daxis.x = [prim virtualWidth] / 2;
    _2Daxis.y = [prim virtualHeight] / 2;


    static LPTriangle tempTriangle = {0};
    
    tempTriangle.p1 = [EngineTransforms rotate2DAtAxis:_2Daxis WithPoint:testTriangle.p1 AtAngle:currentRadian];
    tempTriangle.p2 = [EngineTransforms rotate2DAtAxis:_2Daxis WithPoint:testTriangle.p2 AtAngle:currentRadian];
    tempTriangle.p3 = [EngineTransforms rotate2DAtAxis:_2Daxis WithPoint:testTriangle.p3 AtAngle:currentRadian];

    [prim setColorWithRed:255 Green:0 Blue:255];
    [prim drawTriangle:&tempTriangle];
    
    currentRadian += 0.01;
    currentRadian = currentRadian >= (M_PI * 2) ? currentRadian - (M_PI * 2): currentRadian;
}

@end
