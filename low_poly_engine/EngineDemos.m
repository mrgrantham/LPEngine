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
#import "EngineModel.h"
#import "EngineModelInterface.h"
#import "Arwing.h"

@implementation EngineDemos

+ (id) sharedManager {
    static EnginePrimitives *sharedEnginePrimitives = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEnginePrimitives = [[self alloc] init];
    });
    return sharedEnginePrimitives;
}

- (void)triangleDemo {
    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    
    static LPPoint _2Daxis;
    static float currentRadian = 0.0;
    static LPTriangle testTriangle;
    testTriangle = LPTriangleMake(LPPointMake(40,40,0), LPPointMake(120,60,0), LPPointMake(90,120,0));
    _2Daxis.x = [prim virtualWidth] / 2;
    _2Daxis.y = [prim virtualHeight] / 2;


    static LPTriangle tempTriangle = {0};
    
    tempTriangle.p1 = [EngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p1
                                               AtAngle:currentRadian];
    tempTriangle.p2 = [EngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p2
                                               AtAngle:currentRadian];
    tempTriangle.p3 = [EngineTransforms rotate2DAtAxis:_2Daxis
                                             ForPoint:testTriangle.p3
                                               AtAngle:currentRadian];

    [prim setColorWithRed:255 Green:0 Blue:255];
    [prim drawTriangle:&tempTriangle];
    
    currentRadian += 0.01;
    currentRadian = currentRadian >= (M_PI * 2) ? currentRadian - (M_PI * 2): currentRadian;
}

- (void)arwingDemo {
//    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    static float currentRadian = 0.0;
    if (self.arwing == nil) {
        EngineModelInterface *modelProperties = [[EngineModelInterface alloc] init];
        modelProperties.vertices = (int16_t*)arwingVertices;
        modelProperties.vertexCount = sizeof(arwingVertices) / (sizeof(int16_t) * 3);
        modelProperties.faces = (int16_t*)arwingFaces;
        modelProperties.faceCount = sizeof(arwingFaces) / (sizeof(int16_t) * 3);
        
        self.arwing = [[EngineModel alloc] initWithProperties:modelProperties];
    }
    

    
//    static LPPoint translation = {};
//    translation.x = prim.virtualWidth / 2;
//    translation.y = prim.virtualHeight / 4;
//    translation.z = 1;
//    arwing.translation = translation;
    
//    static float radians = 0.4;
//    static LPPoint rotation = {};
//    rotation.y = radians;
//    self.arwing.rotation = rotation;
    
//    radians += 0.01;
//    if (radians >= 2.0 * M_PI) radians = 0.0;
    [[EnginePrimitives sharedManager] resetDepthBuffer];
    [self.arwing findVertexCenter];
    self.arwing.rotationAxis = self.arwing.center;
    [self.arwing transformVertices];
    
    [self.arwing draw:LPEngineDrawSolid];
    
    currentRadian += 0.001;
    currentRadian = currentRadian >= (M_PI * 2) ? currentRadian - (M_PI * 2): currentRadian;

}

@end
