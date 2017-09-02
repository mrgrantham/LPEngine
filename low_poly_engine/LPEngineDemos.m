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
#import "LPEngineDemos.h"
#import "LPEngineModel.h"
#import "LPEngineModelInterface.h"
#import "Arwing.h"

@implementation LPEngineDemos

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
            LPEngineModelInterface *modelProperties = [[LPEngineModelInterface alloc] init];
            modelProperties.vertices = (int16_t*)arwingVertices;
            modelProperties.vertexCount = sizeof(arwingVertices) / (sizeof(int16_t) * 3);
            modelProperties.faces = (int16_t*)arwingFaces;
            modelProperties.faceCount = sizeof(arwingFaces) / (sizeof(int16_t) * 3);
            modelProperties.lightSource = LPPointMake(1, -1, -1);
            
            _arwing = [[LPEngineModel alloc] initWithProperties:modelProperties];
            LPPoint translation = {};
            EnginePrimitives *prim = [EnginePrimitives sharedManager];
            translation.x = prim.virtualWidth / 2;
            translation.y = prim.virtualHeight / 4;
            translation.z = -800;
            _arwing.translation = translation;
            LPPoint scale = {.x=2.0, .y=2.0, .z=2.0};
            _arwing.scale = scale;
            _arwing.centerChanged = YES;
            [_arwing findVertexCenter];
            _rotateContinuous = NO;
            
            
            
            // break in to separate method later
            LPPoint rotateVector = {};
            rotateVector.y = 3*M_PI/4;
            [self resetArwing];
            [self resetFlight];
            [_arwing rotateWithVector:rotateVector];
            
//            _rotationRadians = {};
//            _translationRadians = {};
//            _scaleRadians = {};
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
    static LPPoint translationVector = {};

    
    if (self.rotateContinuous) {
        static LPPoint rotationVector = {};
        rotationVector.y = 0.015;
        [self.arwing rotateWithVector:rotationVector];
    }
    if (self.translateContinuous) {
        static float translationRadian = M_PI / 2;
        translationVector.x = (sin(translationRadian) * 50) ;
        [self.arwing translateWithVector:translationVector];
        translationRadian += 0.1;
        translationRadian = translationRadian >= (M_PI * 2) ? translationRadian - (M_PI * 2): translationRadian;
    }
    if (self.scaleContinuous) {
        static float scaleRadian = 0.0;
        static LPPoint scaleVector = {};
        float sineValue = sin(scaleRadian);
//        NSLog(@"sineValue: %0.2f", sineValue);
        scaleVector.x = sineValue * 0.02;
        scaleVector.y = sineValue * 0.02;
        scaleVector.z = sineValue * 0.02;

        [self.arwing scaleWithVector:scaleVector];
        scaleRadian += 0.1;
        scaleRadian = scaleRadian >= (M_PI * 2) ? scaleRadian - (M_PI * 2): scaleRadian;
    }
    if (self.flyContinuous) {
        static LPPoint translateVector = {};
        float sineValue = sin(self.translationRadians.y - (M_PI/2));
//        NSLog(@"Translation sineValue: %0.2f", sineValue);
        translateVector.x = 0;
        translateVector.y = sineValue * 5;
        translateVector.z = 0;
        [self.arwing translateWithVector:translateVector];
        
        sineValue = sin(self.rotationRadians.x + (1.22   *M_PI));
//        NSLog(@"Rotation sineValue: %0.2f",sineValue);
        static LPPoint rotateVector = {};
        //        NSLog(@"sineValue: %0.2f", sineValue);
        rotateVector.x = sineValue * 0.17;
        rotateVector.y = self.arwing.rotation.y;
        rotateVector.z = 0;
        self.arwing.rotation = rotateVector;
        
        
        LPPoint temp = self.translationRadians;
        temp.y += 0.02;
        temp.y = temp.y >= (M_PI * 2) ? temp.y - (M_PI * 2): temp.y;
        self.translationRadians = temp;
        
        temp = self.rotationRadians;
        temp.x += 0.02;
        temp.x = temp.x >= (M_PI * 2) ? temp.x - (M_PI * 2): temp.x;
        self.rotationRadians = temp;
    }
    
    [[EnginePrimitives sharedManager] resetDepthBuffer];
    [self.arwing findVertexCenter];
    self.arwing.rotationAxis = self.arwing.center;
    [self.arwing transformVertices];
    
    [self.arwing draw:LPEngineDrawSolid];
    
}

- (void) resetArwing {
    EnginePrimitives *prim = [EnginePrimitives sharedManager];
    self.scaleContinuous = NO;
    self.rotateContinuous = NO;
    self.translateContinuous = NO;
    [self.arwing resetTransforms];
    LPPoint scale = {.x=2.0, .y=2.0, .z=2.0};
    self.arwing.scale = scale;
    LPPoint translation = {};
    translation.x = prim.virtualWidth / 2;
    translation.y = prim.virtualHeight / 4;
    translation.z = -800;
    self.arwing.translation = translation;
}

- (void) resetFlight {
    LPPoint resetPoint = {};
    self.scaleRadians = resetPoint;
    
    //resetPoint.y = M_PI/8;
    self.translationRadians = resetPoint;

    resetPoint.x = M_PI/2;
    self.rotationRadians = resetPoint;
}

@end
