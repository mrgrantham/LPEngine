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

- (id) init {
    if (self = [super init]) {
        if (_arwing == nil) {
            EngineModelInterface *modelProperties = [[EngineModelInterface alloc] init];
            modelProperties.vertices = (int16_t*)arwingVertices;
            modelProperties.vertexCount = sizeof(arwingVertices) / (sizeof(int16_t) * 3);
            modelProperties.faces = (int16_t*)arwingFaces;
            modelProperties.faceCount = sizeof(arwingFaces) / (sizeof(int16_t) * 3);
            
            _arwing = [[EngineModel alloc] initWithProperties:modelProperties];
            LPPoint translation = {};
            EnginePrimitives *prim = [EnginePrimitives sharedManager];
            translation.x = prim.virtualWidth / 2;
            translation.y = prim.virtualHeight / 4;
            translation.z = -800;
            _arwing.translation = translation;
            LPPoint scale = {.x=0.8, .y=0.8, .z=0.8};
            _arwing.scale = scale;
            _arwing.centerChanged = YES;
            [_arwing findVertexCenter];
            _rotateContinuous = YES;

        }
    }
    return self;
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
    static float currentRadian = 0.0;

//    static float radians = 0.4;
//    static LPPoint rotation = {};
//    rotation.y = radians;
//    self.arwing.rotation = rotation;
    
//    radians += 0.01;
//    if (radians >= 2.0 * M_PI) radians = 0.0;
    
    if (self.rotateContinuous) {
        static LPPoint rotationVector = {};
        rotationVector.y = 0.02;
        [self.arwing rotateWithVector:rotationVector];
    }
    if (self.translateContinuous) {
        static float translationRadian = M_PI / 2;
        static LPPoint translationVector = {};
        translationVector.x = (sin(translationRadian) * 10) ;
        [self.arwing translateWithVector:translationVector];
        translationRadian += 0.1;
        translationRadian = translationRadian >= (M_PI * 2) ? translationRadian - (M_PI * 2): translationRadian;
    }
    if (self.scaleContinuous) {
        static float scaleRadian = 0.0;
        static LPPoint scaleVector = {};
        float sineValue = sin(scaleRadian);
//        NSLog(@"sineValue: %0.2f", sineValue);
        scaleVector.x = sineValue * 0.01;
        scaleVector.y = sineValue * 0.01;
        scaleVector.z = sineValue * 0.01;

        [self.arwing scaleWithVector:scaleVector];
        scaleRadian += 0.1;
        scaleRadian = scaleRadian >= (M_PI * 2) ? scaleRadian - (M_PI * 2): scaleRadian;
    }
    
    [[EnginePrimitives sharedManager] resetDepthBuffer];
    [self.arwing findVertexCenter];
    self.arwing.rotationAxis = self.arwing.center;
    [self.arwing transformVertices];
    
    [self.arwing draw:LPEngineDrawSolid];
    
    currentRadian += 0.001;
    currentRadian = currentRadian >= (M_PI * 2) ? currentRadian - (M_PI * 2): currentRadian;

}

- (void) resetArwing {
    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    self.scaleContinuous = NO;
    self.rotateContinuous = NO;
    self.translateContinuous = NO;
    [self.arwing resetTransforms];
    LPPoint scale = {.x=0.8, .y=0.8, .z=0.8};
    self.arwing.scale = scale;
    LPPoint translation = {};
    translation.x = prim.virtualWidth / 2;
    translation.y = prim.virtualHeight / 4;
    translation.z = -800;
    self.arwing.translation = translation;
}

@end
